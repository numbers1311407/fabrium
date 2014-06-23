module Fabrics::Weight
  extend ActiveSupport::Concern

  OSY_CONSTANT = 0.0297

  def gsm=(v)
    write_attribute(:gsm, v)
    write_attribute(:glm, v * width / 100)
    write_attribute(:osy, v * OSY_CONSTANT)
  end

  def glm=(v)
    self.gsm = v / width * 100 rescue 0
  end

  def osy=(v)
    self.gsm = v / OSY_CONSTANT
  end

  def width=(v)
    retv = write_attribute(:width, v)
    self.gsm = self.gsm
    retv
  end
end
