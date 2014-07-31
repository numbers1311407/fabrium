class ProfilesController < ResourceController
  defaults singleton: true, resource_class: User, route_instance_name: :profile

  protected

  def resource
    current_user
  end

  def after_commit_redirect_path
    edit_resource_path
  end
end
