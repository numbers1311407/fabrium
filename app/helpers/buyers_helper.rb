module BuyersHelper
  def buyer_address buyer
    render "shared/address", address: buyer
  end

  def buyers_scope_select_tag
    scope_select_tag :buyers
  end
end
