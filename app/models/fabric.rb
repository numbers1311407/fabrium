class Fabric < ActiveRecord::Base
  include Fabrics::Prices
  include Fabrics::Properties

  belongs_to :mill

  # gsm: weight in GSM, decimal precision 2
  #   glm: f(gsm, width) -> gsm * width / 100
  #   ozy: f(gsm) -> gsm * 0.0297
  #   (write calculations mixin, ozy_to_gsm, gsm_to_glm, etc)

  # width: whole number (unit for display?)
  # country: string (country code)
end
