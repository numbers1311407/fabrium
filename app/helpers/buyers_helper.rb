module BuyersHelper
  def buyer_address buyer
    render "shared/address", address: buyer
  end
end
