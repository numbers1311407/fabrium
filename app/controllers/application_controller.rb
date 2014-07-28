class ApplicationController < ActionController::Base
  before_filter :authenticate_user!

  layout :determine_layout

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def determine_layout
    false if request.xhr?
  end
end
