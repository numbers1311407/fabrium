module TranslationHelper
  def scoped_translate key, *args
    options = args.extract_options!

    _resource = options.delete(:resource) ||
      respond_to?(:maybe_resource) && maybe_resource

    _resource_class = if _resource
      _resource.class
    elsif respond_to?(:resource_class) && resource_class
      resource_class
    end

    aname = options.delete(:action)
    cname = options.delete(:controller) || 
      (_resource_class && _resource_class.model_name.collection) ||
      controller_name

    # typically create errors will render new and update
    # errors will re-render edit.  This is the peril of relying
    # on action name, I guess.  Kludgy, but this will fix the
    # translation in most cases (create and update are not 
    # typically templated)
    aname ||= case action_name
              when "create" then "new"
              when "update" then "edit"
              else action_name
              end

    defaults = []

    defaults << :"st.#{cname}.actions.#{aname}.#{key}"
    defaults << :"st.#{cname}.#{key}"
    defaults << :"st.actions.#{aname}.#{key}"
    defaults << :"st.#{key}"

    options ||= {}

    options[:default] = defaults

    if _resource_class
      options[:Resource] = _resource_class.model_name.human
      options[:Collection] = _resource_class.model_name.human.pluralize
      options[:resource] = options[:Resource].downcase
      options[:collection] = options[:Collection].downcase
      options[:resources] = options[:resource].pluralize
    end

    I18n.t(defaults.shift, options)
  end

  alias :st :scoped_translate
end
