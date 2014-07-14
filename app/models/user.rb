class User < ActiveRecord::Base
  include Users::BelongsToMeta

  devise :database_authenticatable, 
    :invitable, 
    :registerable,
    :recoverable, 
    :trackable, 
    :timeoutable,
    :validatable, 
    :lockable
end
