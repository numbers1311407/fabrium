class MailerJob
  include SuckerPunch::Job

  def perform(mailer, method, *args)
    ActiveRecord::Base.connection_pool.with_connection do
      Rails.logger.info("MailerJob starting: #{mailer.to_s}.#{method.to_s}")
      mail = mailer.send(method, *args)
      mail.deliver if mail
    end
  end
end
