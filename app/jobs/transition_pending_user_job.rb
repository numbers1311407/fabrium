class TransitionPendingUserJob
  include SuckerPunch::Job

  def perform(user_id)
    activate_user(user_id)
    process_pending_user_carts(user_id)
  end

  def activate_user(user_id)
    MailerJob.new.async.perform(AppMailer, :user_activated, user_id)
  end

  def process_pending_user_carts(user_id)
    ProcessOrderJob.new.async.perform(:process_pending_user_carts, user_id)
  end
end
