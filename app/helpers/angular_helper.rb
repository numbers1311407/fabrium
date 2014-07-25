module AngularHelper
  def select_options_for_categories
    options_for_select(Property.categories.order(name: :asc).pluck(:name, :id))
  end

  def select_options_for_fiber
    options_for_select(Property.fibers.order(name: :asc).pluck(:name, :id))
  end
end
