class ApplicationController < ActionController::Base
  before_filter :authenticate_user!

  include FlashToHeaders
  include DeterminesLayout
  include AngularCsrf

  rescue_from ActionController::UnknownFormat, with: :render_406

  rescue_from ActionView::MissingTemplate, with: :render_404
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, :with => :render_404


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def routing_error
    raise ActionController::RoutingError.new(params[:path] || "/routing_error")
  end

  protected

  def render_406
    render file: 'public/406.html', layout: false, status: 406
  end

  def render_404
    render file: 'application/404', status: 404
  end

  def initiate_async_jobs
    CleanupFabricVariantOrphansJob.new.perform
  end

  # Can't go to root on sign out, as it's a protected page
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  # Send users to different places on login by default.  Note this will
  # be overridden if the user is redirected to sign in when trying to view
  # an auth protected page.  Sign in should then continue to where they
  # attempted to go.
  def signed_in_root_path(resource)
    meta_type = resource.respond_to?(:meta_type) && resource.meta_type.human

    case meta_type
    when 'admin'
      users_path(scope: 'pending')
    when 'buyer'
      root_path
    when 'mill'
      carts_path(scope: 'ordered')
    else
      super
    end
  end

  # NOTE using this for a hook only.  
  #
  def after_sign_in_path_for(resource_or_scope)
    if resource.respond_to?(:is_admin?) && resource.is_admin?
      initiate_async_jobs
    end

    super
  end

  # By default it is the root_path.
  def after_sign_out_path_for(resource_or_scope)
    "http://fabrium.com"
  end
end
