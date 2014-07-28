module FlashHelper
  def alert_class(type)
    typeclass = case type
    when 'alert' then 'alert-danger'
    when 'notice' then 'alert-success'
    end

    "alert #{typeclass}"
  end
end
