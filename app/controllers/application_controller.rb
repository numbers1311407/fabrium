class ApplicationController < ActionController::Base
  before_filter :authenticate_user!

  rescue_from ActionController::UnknownFormat, with: :render_406

  layout :determine_layout

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def determine_layout
    false if request.xhr?
  end

  def render_406
    render file: 'public/406.html', layout: false, status: 406
  end
end
