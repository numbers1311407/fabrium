class AppMailer < ActionMailer::Base
  helper FabricsHelper

  default from: "support@fabrium.com",
           bcc: "support@fabrium.com"
  
  def mill_cart_created(cart)
    @cart = cart
    @mill = cart.creator
    subject = "#{@mill.name} has created a portfolio of fabrics for you to review at Fabrium.com."
    @cart_url = cart.public? ? public_cart_url(cart.public_id) : cart_url(cart)
    mail(to: cart.buyer_email, subject: subject)
  end

  def user_activated(user_id)
    @user = User.find(user_id)
    subject = "Your account at Fabrium.com has been activated"
    mail(to: @user.email, subject: subject)
  end

  # email mill user(s) when order received (by preference?)
  def order_received(cart, users)
    @cart = cart
    subject = "You've received an order at Fabrium.com"
    mail(to: users.map(&:email), subject: subject)
  end

  # email buyer when order shipped
  def order_shipped(cart, user, mill)
    @cart, @user, @mill = cart, user, mill
    subject = "#{@mill.name} has shipped your fabric request from Fabrium.com"
    mail(to: @user.email, subject: subject)
  end

  # email buyer when order refused
  def order_refused(cart, user, mill)
    @cart, @user, @mill = cart, user, mill
    subject = "#{@mill.name} has declined to fulfill your fabric request at Fabrium.com"
    mail(to: @user.email, subject: subject)
  end
end
