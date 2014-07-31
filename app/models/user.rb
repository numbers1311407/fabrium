class User < ActiveRecord::Base
  include Authority::UserAbilities
  include Authority::Abilities

  include Users::BelongsToMeta

  has_many :favorites
  has_many :favorite_fabric_variants, through: :favorites, source: :fabric_variant

  define_meta_types :admin, :mill, :buyer

  devise :database_authenticatable, 
    :invitable, 
    :registerable,
    :recoverable, 
    :trackable, 
    :timeoutable,
    :validatable, 
    :lockable

  # don't require password on creation as users are created in the admin
  def password_required?
    super if persisted?
  end
end
