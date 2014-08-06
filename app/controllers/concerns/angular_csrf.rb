module AngularCsrf
  extend ActiveSupport::Concern

  included do
    after_filter :set_csrf_cookie_for_ng
  end

  protected

  #
  # Angular XSRF
  #
  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

end
