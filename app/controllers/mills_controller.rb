class MillsController < ResourceController
  has_scope :id do |controller, scope, value|
    scope.where(id: value.split(','))
  end
end
