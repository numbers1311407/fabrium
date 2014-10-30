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

  def translate_scope_name scope, type
    Rails.logger.error "#{scope} #{type}"
    t(:"scopes.#{type}.#{scope}", default: [:"scopes.#{scope}"])
  end

  def scope_select_tag scope
    options = scope_options.map do |option|
      scope_name = translate_scope_name(option, scope)
      [scope_name, option]
    end

    options.unshift [translate_scope_name(:all, scope), ""]

    options = options_for_select(options, params[:scope])

    html_options = {}
    html_options[:class] = 'form-control'
    html_options[:data] = {select: {plugins: {route_on_change: {remote: true}}}}

    select_tag :scope, options, html_options
  end

  def humanize_boolean(v)
    t(v ? :"boolean.yes" : :"boolean.no")
  end

  def fake_input attr, object
    html = ''.html_safe.tap do |out|
      out << content_tag(:label, resource_label(attr, object), class: 'control-label')
      out << content_tag(:p, object.send(attr), class: 'fake-input form-control-static form-control')
    end

    content_tag(:div, html, class: 'form-group')
  end


  def panel_class(value=nil)
    @panel_class ||= []

    if value
      @panel_class << value
    end

    @panel_class.join(' ')
  end


  def association_select_tag(name, select_options, endpoint)
    options = {
      include_blank: true,
      data: {
        select: {
          placeholder: "Type to Search",
          plugins: {
            # passing `blank` as false because we're using the clear
            # selection plugin here (this is a type to search field)
            route_on_change: {remote: true, blank: false}, 
            endpoint: {url: endpoint},
            clear_selection: {}
          } 
        }
      }
    }

    select_tag name, options_for_select(select_options), options
  end
end
