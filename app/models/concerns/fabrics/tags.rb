module Fabrics
  #
  # Tags doesn't use a relation at all, but rather a postgres array
  # column of strings.  This was done primarily to simplify the search
  # query, particulary when searching doing a "match all" tag search,
  # which needs to be handled with a group & count construct when using
  # the typical `tagging` join table pattern.
  #
  # Using an array avoids query complexity both when searching, and when
  # simply loading tags, as tags are string literal values on the record
  # and do not require any table joins.
  #
  module Tags
    extend ActiveSupport::Concern

    included do
      # Tags are always downcased.  This is necessary as case-insensitive
      # array inclusion queries are not possible.
      before_validation :downcase_tags

      # Tags should probably be sorted by name, we'll see after feedback...
      before_validation :sort_tags
    end

    def tag_ids
      tag_records.pluck(:id)
    end

    def tag_ids=(ids)
      self.tags = Tag.where(id: ids).pluck(:name).sort
    end

    def tag_records
      Tag.where(name: tags)
    end

    module ClassMethods
      def tags(list)
        return none if list.blank?

        # accepts either an array of terms or a string delimited by
        # commas
        list = list.split(',') if list.is_a?(String)

        # split up into "partial" term matches and exact tag matches
        partials, exacts = list.partition {|item| item.match(/\*$/) }

        conditions = []
        # For partial searches we'll search for matching tag first, then
        # add an overlap condition that the fabric has at least one of the
        # found tags.
        #
        # If no tags are found at all by the partial term, return `none`
        # immediately
        partials.each do |partial|
          # match both sides of the term
          term = "%#{partial.delete('*')}%"
          tags = Tag.name_like(term).all
          raise ActiveRecord::RecordNotFound, "Tag match not found" if tags.empty?
          tag_names = tags.map {|t| t.name.downcase }
          conditions << arel_table[:tags].overlaps(tag_names)
        end

        # exact matches are simple, just look for the downcased term
        if exacts.any?
          conditions << arel_table[:tags].contains(exacts.map(&:downcase))
        end

        where conditions.inject(&:and)
      rescue ActiveRecord::RecordNotFound
        none
      end


      #
      # The class methods are for operating on existing tags across the
      # whole collection.  This is required as while tags are stored as
      # denormalized strings, they are still related to `Tag` records and
      # should reflect changes to those tags and be removed upon their
      # deletion
      #

      ## 
      # Remove a tag across the table
      #
      def remove_tag tag
        tag.downcase!
        tags(tag).update_all ["tags = array_remove(tags, ?)", tag.downcase]
      end

      ##
      # Edit a tag across the table
      #
      def edit_tag tag, value
        tag, value = tag.downcase, value.downcase
        tags(tag).update_all ["tags = array_replace(tags, ?, ?)", tag, value]
      end
    end

    protected

    def downcase_tags
      self.tags = self.tags.map {|t| t.downcase }
    end

    def sort_tags
      self.tags.sort!
    end
  end
end
