module ApplicationHelper

  def title(page_title=nil, options={})
    @_title ||= []

    if page_title
      (@_title << page_title).last
    else
      @_title.unshift t(:site_title)
      @_title.compact.join(" - ")
    end
  end
end
