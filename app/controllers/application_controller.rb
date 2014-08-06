class ApplicationController < ActionController::Base
  before_filter :authenticate_user!

  include FlashToHeaders
  include DeterminesLayout
  include AngularCsrf

  rescue_from ActionController::UnknownFormat, with: :render_406
  # rescue_from ActionView::MissingTemplate, with: :render_404


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  protected

  def render_406
    render file: 'public/406.html', layout: false, status: 406
  end

  def render_404
    render file: 'public/404.html', layout: false, status: 404
  end

  def initiate_async_jobs
    CleanupFabricVariantOrphansJob.new.perform
  end

  def after_sign_in_path_for(resource_or_scope)
    if resource.respond_to?(:is_admin?) && resource.is_admin?
      initiate_async_jobs
    end

    super
  end
end
