module Resources
  module Pagination
    extend ActiveSupport::Concern

    included do
      has_scope :page, default: 1
      has_scope :per
      has_scope :padding

      before_filter :set_pagination, only: :index
    end

    protected

    def set_pagination
      page = collection.current_page
      pages = collection.total_pages
      per_page = collection.limit_value
      total_count = collection.total_count

      headers['X-Pagination'] = {
        page: page,
        pages: pages,
        per_page: per_page,
        total_count: total_count,
        from: (page - 1) * per_page + 1,
        to: [page * per_page, total_count].min
      }.to_json
    end

  end
end
