module AngularHelper
  def select_options_for_categories
    options_for_select(Category.all.order(name: :asc).pluck(:name, :id))
  end

  def select_options_for_material
    options_for_select(Material.all.order(name: :asc).pluck(:name, :id))
  end

  def select_options_for_dye_method
    options_for_select(DyeMethod.all.order(name: :asc).pluck(:name, :id))
  end
end
