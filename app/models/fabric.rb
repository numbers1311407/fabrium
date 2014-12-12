class Fabric < ActiveRecord::Base
  include Authority::Abilities

  include Fabrics::Prices
  include Fabrics::Category
  include Fabrics::DyeMethod
  include Fabrics::Tags
  include Fabrics::Materials
  include Fabrics::Variants
  include Fabrics::Category
  include Fabrics::Weight
  include Fabrics::Mill

  has_many :favorites, dependent: :delete_all
  has_many :favoriting_users, through: :favorites, source: :user

  # the Fabric's "Fabrium ID" is just the actual ID, but this has the same
  # scope as fabric variant for consistency
  scope :fabrium_id, ->(val) { where(id: val) }
  scope :item_number, ->(val) { where(item_number: val) }
  scope :bulk_lead_time, ->(val) { where(arel_table[:bulk_lead_time].lteq(val)) }
  scope :bulk_minimum_quality, ->(val) { where(arel_table[:bulk_minimum_quality].lteq(val)) }
  scope :sample_lead_time, ->(val) { where(arel_table[:sample_lead_time].lteq(val)) }
  scope :sample_minimum_quality, ->(val) { where(arel_table[:sample_minimum_quality].lteq(val)) }
  scope :country, ->(val) { where(country: val) }
  scope :favorites, ->(user) { joins(:favorites).merge(Favorite.for_user(user)) }
  scope :archived, ->(val=true) { where(archived: val) }

  has_many :fabric_notes, dependent: :delete_all

  validates :width, numericality: { greater_than: 0 }, presence: true
  validates :mill, presence: true
  validates :item_number, presence: true, uniqueness: { scope: :mill_id }
  validates :weight, presence: true
  validates :bulk_minimum_quality, numericality: { greater_than_or_equal_to: 0 }
  validates :sample_minimum_quality, numericality: { greater_than_or_equal_to: 0 }

  validates :category, presence: true
  validates :dye_method, presence: true
  validates :fabric_variants, length: { minimum: 1 }
end
