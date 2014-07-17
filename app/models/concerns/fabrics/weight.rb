module Fabrics::Weight
  extend ActiveSupport::Concern

  OSY_CONSTANT = 0.0297
  UNITS = %w(gsm glm osy)

  included do
    before_save :convert_weights
  end

  def weight_units
    @weight_units || UNITS[0]
  end

  def weight_units=(v)
    @weight_units = v.to_s if UNITS.member?(v.to_s)
  end

  def weight
    @weight || send(weight_units)
  end

  def weight=(v)
    @weight = v
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
