class MillReference < ActiveRecord::Base
  belongs_to :mill

  phony_normalize :phone, :default_country_code => 'US'
  validates :name, presence: true
  validates :email, presence: true, email: true
  validates :phone, presence: true, phony_plausible: true
  validates :company, presence: true
end
