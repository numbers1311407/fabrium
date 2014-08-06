module Fabrics::Weight
  extend ActiveSupport::Concern

  OSY_CONSTANT = 0.0297
  WEIGHT_UNITS = %w(gsm glm osy)

  included do

    # This feels a little unsafe, but the way fabric weights work, the
    # weight is only set via `weight=`.  To make this feel safe, there'd
    # need to be a "base weight" column and mutators for each of the weights,
    # which would convert from that weight, set the base weight, and then
    # reconvert the other weights.  
    #
    # The first implementation of weights actually did something like 
    # this, but it felt overcomplicated, particularly because GLM is 
    # dependent on width.  This meant that setting the glm when the width
    # was off would recalculate the other two as 0.
    #
    # Even in this implementation, there's still the matter of GLM
    # being dependent on width, which may change after the GLM is set
    # and thus invalidate the GLM.  
    #
    # I think in reality, users should not be able to SET weight as any 
    # unit, but rather GLM and Oz/y would both be calculated on save
    # (Oz/y whenever GSM changes, GLM whenever width OR GLM changes).
    # This, however, was not the spec, but we may end up going back to
    # this.  Is there a reason people can't enter the weight as GLM?
    # No there is not.
    #
    before_save :convert_weights, if: :weight_set?

    scope :weight, ->(v, units=nil) {
      conditions = {}
      conditions[parse_units(units)] = v
      where(conditions)
    }
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

  def weight_set?
    !@weight.nil?
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
