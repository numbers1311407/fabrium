class PropertiesController < ResourceController
  custom_actions collection: [:keywords, :categories, :dye_methods]

  has_scope :name do |controller, scope, value|
    scope.name_like("#{value}%")
  end

  def apply_collection_filter_scopes(object)
    case action_name
    when 'keywords', 'categories', 'dye_methods'
      object = object.send(action_name)
    end

    object
  end
end
