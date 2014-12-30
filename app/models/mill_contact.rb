class MillContact < ActiveRecord::Base
  include HasPhone
  belongs_to :mill

  validates :kind, presence: true
  validates :name, presence: true
  validates :email, presence: true, email: true
  validates :phone, presence: true
end
