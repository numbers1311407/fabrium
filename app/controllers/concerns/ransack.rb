module Concerns
  module Ransack
    extend ActiveSupport::Concern

    included do
      add_collection_filter_scope :apply_search_filter

      class_attribute :default_sort
      self.default_sort = {name: 'created_at', dir: 'desc'}
    end

    protected

      def apply_search_filter(object)
        @q = object.search(params[:q])
        if self.default_sort && @q.sorts.empty?
          @q.sorts = [self.default_sort]
        end

        @q.result
      end

  end
end
