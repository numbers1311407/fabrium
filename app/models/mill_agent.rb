class MillAgent < ActiveRecord::Base
  belongs_to :mill

  phony_normalize :phone, :default_country_code => 'US'
  validates :contact, presence: true
  validates :email, presence: true, email: true
  validates :phone, presence: true, phony_plausible: true
  validates :country, presence: true
end
