class AppMailer < ActionMailer::Base
  default from: "admin@fabrium.com"
  
  def mill_cart_created(cart)
    @cart = cart
    @mill = cart.creator
    mail(to: cart.buyer_email, subject: "A fabric hanger cart has been created for you by #{@mill.name}")
  end

  def user_activated(user_id)
    @user = User.find(user_id)
    mail(to: @user.email, subject: "Your account at Fabrium has been activated")
  end
end
