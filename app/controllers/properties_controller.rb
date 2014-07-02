class PropertiesController < ResourceController
  custom_actions collection: :keywords

  has_scope :name do |controller, scope, value|
    scope.name_like("#{value}%")
  end

  def keywords
    respond_with(collection)
  end

  def apply_collection_filter_scopes(object)
    case action_name
    when 'keywords' then object = object.keywords
    end

    object
  end
end
