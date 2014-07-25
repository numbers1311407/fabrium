module Fabrics::Weight
  extend ActiveSupport::Concern

  OSY_CONSTANT = 0.0297
  WEIGHT_UNITS = %w(gsm glm osy)

  included do
    before_save :convert_weights
  end

  def weight_units
    @weight_units || self.class.default_weight_units
  end

  def weight_units=(v)
    @weight_units = v.to_s if WEIGHT_UNITS.member?(v.to_s)
  end

  def weight
    @weight || send(weight_units)
  end

  def weight=(v)
    @weight = v
  end

  module ClassMethods
    def default_weight_units
      WEIGHT_UNITS[0]
    end

    def parse_units(v)
      return default_weight_units unless v.present?
      found = WEIGHT_UNITS.detect {|unit| unit == v.downcase }
      found || default_weight_units
    end
  end

  protected

  def convert_weights
    as_gsm = case weight_units
      when 'gsm' then weight.to_f
      when 'glm' then weight.to_f / width * 100
      when 'osy' then weight.to_f / OSY_CONSTANT
    end
    
    self.gsm = as_gsm
    self.glm = as_gsm * width / 100
    self.osy = as_gsm * OSY_CONSTANT
  end
end
