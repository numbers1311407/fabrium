class User < ActiveRecord::Base
  include Authority::UserAbilities

  include Users::BelongsToMeta

  has_many :favorites

  define_meta_types :admin, :mill, :buyer

  devise :database_authenticatable, 
    :invitable, 
    :registerable,
    :recoverable, 
    :trackable, 
    :timeoutable,
    :validatable, 
    :lockable
end
