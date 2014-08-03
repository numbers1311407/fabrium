class ProfilesController < ResourceController
  self.layout_name = 'profile'

  defaults singleton: true, resource_class: User, route_instance_name: :profile, instance_name: :user

  custom_actions resource: :blocklist

  permit_params [
    :password,
    :password_confirmation,
    meta_attributes: [
      :domain_filter, 
      :domain_names
    ]
  ]

  def show
    show! do |wants|
      wants.html { redirect_to edit_resource_path }
    end
  end

  protected

  def resource
    current_user
  end

  def after_commit_redirect_path
    Rails.logger.error(request.referer)
    case request.referer
    when /blocklist$/ then blocklist_resource_path
    else edit_resource_path
    end
  end
end
