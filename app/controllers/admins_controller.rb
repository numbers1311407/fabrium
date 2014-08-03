class AdminsController < ResourceController
  before_filter :build_user, only: :new

  add_collection_filter_scope :collection_filter_scope_joins_user

  self.default_sort = {name: 'user_email', dir: 'asc'}

  permit_params [
    user_attributes: [:id, :email, :wants_email]
  ]

  protected

  def build_user
    build_resource.build_user
  end

  def update_resource(object, attributes)
    super.tap do |result|
      if params[:commit_and_resend_invitation] && result
        flash[:notice] = t("flash.actions.update_and_send_invitation.notice", {
          resource_name: resource_class.model_name.human
        })
        object.user.send_invitation!(current_user)
      end
    end
  end

  def create_resource(object)
    object.user.invited_by = current_user
    object.save
  end

  def collection_filter_scope_joins_user(object)
    object.joins(:user)
  end
end
