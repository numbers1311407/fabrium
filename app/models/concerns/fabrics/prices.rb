module Fabrics::Prices
  extend ActiveSupport::Concern

  def price_eu
    read_converted_price :price_eu
  end

  def price_us
    read_converted_price :price_us
  end

  def price_eu=(val)
    write_converted_price :price_eu, val
  end

  def price_us=(val)
    write_converted_price :price_us, val
  end

  private

  def read_converted_price attr
    val = read_attribute(attr)
    val.first == val.last ? val.first : val
  end

  def write_converted_price attr, val
    val = val..val if Numeric === val
    write_attribute(attr, val)
  end
end
