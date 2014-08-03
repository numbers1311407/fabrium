class InviteUserJob
  include SuckerPunch::Job

  def perform(user_id, inviter_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Rails.logger.info("InviteUserJob starting, user_id:#{user_id}, inviter_id:#{inviter_id}")
      user = User.find(user_id)
      inviter = User.find(inviter_id)
      user.invite!(inviter)
    end
  end
end
