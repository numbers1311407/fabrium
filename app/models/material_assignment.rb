class MaterialAssignment < ActiveRecord::Base
  belongs_to :material, inverse_of: :material_assignments
  belongs_to :fabric
  delegate :name, to: :material, allow_nil: true

  before_save :zero_value

  protected

  def zero_value
    self.value = 0 unless value.present?
  end
end
