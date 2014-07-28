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
      scope :tags, ->(list) {
        list = list.split(',') if list.is_a?(String)
        where.contains(tags: list)
      }

      # Tags are always downcased.  This is necessary as case-insensitive
      # array inclusion queries are not possible.
      before_validation :downcase_tags
    end

    module ClassMethods
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
        tags(tag).update_all ["tags = array_remove(tags, ?)", tag]
      end

      ##
      # Edit a tag across the table
      #
      def edit_tag tag, new_value
        tags(tag).update_all ["tags = array_replace(tags, ?, ?)", tag, new_value]
      end
    end

    protected

    def downcase_tags
      self.tags = self.tags.map {|t| t.downcase }
    end
  end
end
