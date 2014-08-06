class Tag < ActiveRecord::Base
  include Authority::Abilities
  self.authorizer = FabriumResourceAuthorizer

  validates :name, 
    uniqueness: true,
    # `name` should be word chars and underscore.
    #
    # NOTE tag name characters can be expanded to include other characters
    #      if necessary, but it is only critical that they cannot include
    #      a comma, which is the separator for queries
    format: { with: /\A[\w-]+\z/ }

  after_destroy :remove_tag_from_fabrics
  after_update :edit_tag_on_fabrics

  # Tags are always downcased.  This is necessary as case-insensitive
  # array inclusion queries are not possible.
  before_validation :downcase_name

  # all "property" like model should define this scope, here for
  # autocomplete form controls
  scope :name_like, ->(v) { where(arel_table[:name].matches(v)) }

  protected

  def remove_tag_from_fabrics
    Fabric.remove_tag(name)
  end

  def edit_tag_on_fabrics
    Fabric.edit_tag(name_was, name) if name_changed?
  end

  def downcase_name
    self.name = name.downcase
  end
end
