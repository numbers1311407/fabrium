class Fabrium::DeviseMailer < Devise::Mailer
  protected

  def headers_for(action, opts)
    headers = super
    headers[:bcc] = [mailer_sender(devise_mapping)]
    headers
  end
end
