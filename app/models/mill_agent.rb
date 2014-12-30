class MillAgent < ActiveRecord::Base
  include HasPhone
  belongs_to :mill

  validates :contact, presence: true
  validates :email, presence: true, email: true
  validates :phone, presence: true
  validates :country, presence: true
end
