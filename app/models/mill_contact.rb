class MillContact < ActiveRecord::Base
  belongs_to :mill

  phony_normalize :phone, :default_country_code => 'US'
  validates :kind, presence: true
  validates :name, presence: true
  validates :email, presence: true, email: true
  validates :phone, presence: true, phony_plausible: true
end
