require 'active_support/concern'

module Fabrics::Prices
  extend ActiveSupport::Concern

  PRICE_UNITS = %w(us eu)

  included do
    validates :price_us_min, presence: true, 
      numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: :price_us_max }
    validates :price_eu_min, presence: true, 
      numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: :price_eu_max }
    validates :price_us_max, presence: true,
      numericality: { greater_than_or_equal_to: :price_us_min }
    validates :price_eu_max, presence: true,
      numericality: { greater_than_or_equal_to: :price_eu_min }

    before_validation :cast_price_ranges_to_db

    scope :price, ->(v, units=nil) {
      conditions = {}
      conditions[parse_units_column(units)] = v
      where.overlaps(conditions)
    }
  end

  def price_us_min=(v)
    @price_us_min = v.to_f
  end

  def price_us_max=(v)
    @price_us_max = v.to_f
  end

  def price_eu_min=(v)
    @price_eu_min = v.to_f
  end

  def price_eu_max=(v)
    @price_eu_max = v.to_f
  end

  def price_us_min
    @price_us_min ||= price_us.try(:min)
  end

  def price_us_max
    @price_us_max ||= price_us.try(:max)
  end

  def price_eu_min
    @price_eu_min ||= price_eu.try(:min)
  end

  def price_eu_max
    @price_eu_max ||= price_eu.try(:max)
  end

  def pricing_type
    @pricing_type ||= 
      (!price_us.present? || price_us.min == price_us.max) &&
      (!price_eu.present? || price_eu.min == price_eu.max) ? 0 : 1
  end

  def pricing_type=(v)
    @pricing_type = v.to_i
  end

  module ClassMethods
    def default_price_units
      PRICE_UNITS[0]
    end

    def parse_units_column(v)
      units = if v.blank?
        default_price_units
      else
        found = PRICE_UNITS.detect {|unit| unit == v.downcase }
        found || default_price_units
      end

      "price_#{units}"
    end
  end


  protected

  def cast_price_ranges_to_db
    if pricing_type.zero?
      self.price_us_max = price_us_min
      self.price_eu_max = price_eu_min
    end

    self.price_us = price_us_min..price_us_max
    self.price_eu = price_eu_min..price_eu_max
  end
end
