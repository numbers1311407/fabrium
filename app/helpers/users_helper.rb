module UsersHelper
  def current_user_json
    current_user ? UserRepresenter.new(current_user).to_json : ""
  end
end
