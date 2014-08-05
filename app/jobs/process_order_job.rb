class ProcessOrderJob
  include SuckerPunch::Job

  def perform(job, *args)
    ActiveRecord::Base.connection_pool.with_connection do
      send(job, *args)
    end
  end

  def process_pending_user_carts(user_id)
    user = User.find(user_id)
    user.meta.carts.state(:pending).each do |cart|
      cart.state = Cart.states[:ordered]
      cart.save
    end
  end
end
