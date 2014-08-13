module MillsHelper
  def mills_scope_select_tag
    scope_select_tag :mills
  end

  def mills_name_select_tag
    name = :id
    collection = Mill.select(:id, :name).limit(10).order(:name)
    endpoint = mills_path(:json)

    select_options = collection.map {|o| [o.name, o.id] }

    association_select_tag(name, select_options, endpoint)
  end
end
