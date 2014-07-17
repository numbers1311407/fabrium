class PropertySelectInput < SimpleForm::Inputs::Base
  def input(wrapper_options)

    limit = options[:limit] || 10
    order = options[:order] || {name: :asc}

    scope = attribute_name.to_s.singularize
    collection = Property.send(scope).order(order).limit(limit)

    endpoint = @builder.template.send("#{scope}_json_path", format: :json)

    data = input_html_options.delete(:data) || {}
    data.reverse_merge!({ select: {endpoint: {url: endpoint, param: 'name'} } })
    input_html_options[:data] = data

    # fetch out options and apply here if needed (selected, include_blank)
    select_options = {include_blank: true}

    @builder.collection_select(attribute_name, collection, :id, :name, select_options, input_html_options)
  end
end
