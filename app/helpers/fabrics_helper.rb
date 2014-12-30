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
end
