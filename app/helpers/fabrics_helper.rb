module FabricsHelper
  def weeks_select_options
    (1..16).map {|n| ["#{n} Weeks", n] }
  end
end
