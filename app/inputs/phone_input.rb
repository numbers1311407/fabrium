class PhoneInput < SimpleForm::Inputs::StringInput

  def input(wrapper_options={})
    input_html_options[:value] = object.send(attribute_name)
    input_html_options[:type] = 'tel'
    # options[:wrapper_html] = {class: 'popover-hint'}
    # options[:hint] = :translate
    super
  end

end
