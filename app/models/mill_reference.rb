class MillReference < ActiveRecord::Base
  include HasPhone
  belongs_to :mill

  validates :name, presence: true
  validates :email, presence: true, email: true
  validates :phone, presence: true
  validates :company, presence: true
end
