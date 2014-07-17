class FabricWeightInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    units = %w(gsm glm osy)

    out = ''.html_safe

    opts = if @builder.object.persisted?
      { data: @builder.object.attributes.slice(*units) }
    else
      {}
    end
    
    input_html_options[:class] ||= []
    input_html_options[:class].push("form-control")

    out.safe_concat @builder.number_field(:weight, opts.merge(input_html_options))
    out.safe_concat @builder.select(:weight_units, units)

    template.content_tag(:div, out, class: 'fabric_weights_wrapper')
  end
end
