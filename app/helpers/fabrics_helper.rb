module FabricsHelper
  def weeks_select_options
    (1..16).map {|n| ["#{n} Weeks", n] }
  end

  def fabric_path_with_variant(fabric, variant)
    search = {}
    search[:v] = variant.position unless variant.position.zero?
    fabric_path(fabric, search)
  end

  def fabric_price(field, fabric)
    value = fabric.send(field)
    value.present? && !value.zero? ? number_with_precision(value, precision: 2) : nil
  end

  def fabric_price_display(fabric, region, yards=false)
    unit = region == :us ? '$' : '€'
    fields = ["price_#{region}_min", "price_#{region}_max"]
    values = fields.map do |field| 
      val = fabric.send(field)
      val *= 0.9144 if yards
      number_to_currency(val, unit: unit)
    end

    values.first == values.last ? values.first : values.join(' to ')
  end

  def fabric_weight_display(fabric)
    "#{fabric.osy} Oz/y<sup>2</sup>; #{fabric.glm} GLM; #{fabric.gsm} GSM".html_safe
  end
end
