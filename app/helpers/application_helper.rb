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

  def index_table_headers &block
    content_for(:th, &block) unless content_for?(:th)
  end

  def resource_menu_link(resource_class, options={}, &block)
    if current_user && current_user.can_administer?(resource_class.new)
      if block
        capture(&block)
      else
        content_tag(:li) do
          link_to(
            options[:text] || resource_class.model_name.human.pluralize, 
            options[:url] || polymorphic_path(resource_class)
          )
        end
      end
    end
  end

end
