class AppMailer < ActionMailer::Base
  default from: "admin@fabrium.com"
  
  def mill_cart_created(cart)
    @cart = cart
    @mill = cart.creator
    subject = "#{@mill.name} has created a portfolio of fabrics for you to review at Fabrium.com."
    @cart_url = cart.public? ? public_cart_url(cart.public_id) : cart_url(cart)
    mail(to: cart.buyer_email, subject: subject)
  end

  def user_activated(user_id)
    @user = User.find(user_id)
    subject = "Your account at Fabrium has been activated"
    mail(to: @user.email, subject: subject)
  end

  # email mill user(s) when order received (by preference?)
  def order_received()
  end

  # email buyer when order refused
  def order_refused()
  end

  # email buyer when order shipped
  def order_shipped()
  end
end
