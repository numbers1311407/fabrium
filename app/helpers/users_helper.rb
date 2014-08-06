module UsersHelper

  def users_scope_select_tag
    scope_select_tag :users
  end

  def translate_users_scope_name(scope)
    translate_scope_name scope, :users
  end
end
