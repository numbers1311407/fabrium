class UsersController < ResourceController
  self.default_sort = {name: 'email', dir: 'asc'}

  permit_params [
    :email,
    :pending,
    :wants_email,
    :admin,
    :mill,
    mill_ids: []
  ]

  has_scope :mill do |controller, scope, value|
    scope.mills.where(meta_id: value)
  end

  has_scope :scope do |controller, scope, value|
    case value
    when 'pending' then scope = scope.pending
    # when 'mill'    then scope = scope.mills
    # when 'buyer'   then scope = scope.buyers
    # when 'admin'   then scope = scope.admins
    end

    scope
  end

  # eager load the metas
  add_collection_filter_scope :collection_filter_include_meta

  # Only mill users are managed here.  Buyer and admin users are now
  # managed with their meta record.
  add_collection_filter_scope :collection_filter_only_mills

  add_collection_filter_scope :collection_filter_sort_by_mills

  custom_actions resource: [:activate], collection: [:domains]

  authority_actions domains: :read

  respond_to :js, only: :activate

  def domains
    pattern = "SUBSTRING(users.email from '@(.*)$')"

    # we're only searching domains for buyers.  This could be a scope, but,
    # there's no reason to expose anything but buyer domains
    scope = User.where(meta_type: 'Buyer')

    scope = scope.select("#{pattern} as domain_name")
    scope = scope.where("#{pattern} ILIKE ?", "#{params[:name]}%") if params[:name]
    scope = scope.group('domain_name')
    scope = scope.order('domain_name ASC')
    scope = scope.limit(25)

    render json: scope.all.map(&:domain_name)
  end

  def activate
    resource.pending = false
    resource.save

    respond_with(resource)
  end

  protected

  def scope_options
    scopes = %w(pending)
  end
  helper_method :scope_options

  # non admins are scoped to their users (mills, basically, as buyers
  # only have one user and should not have admin access to this page)
  def begin_of_association_chain
    unless current_user.is_admin?
      current_user.meta
    end
  end

  def collection_filter_include_meta(object)
    object.
      includes(:meta).
      joins("JOIN mills ON mills.id = users.meta_id").
      references(:mills)
  end

  def collection_filter_only_mills(object)
    object.mills
  end

  # Ransack (which is probably overkill as it's really used only for sorting)
  # will not sort on the fake mill association.  And it's simpler to just sort
  # after the fact than to try to figure out how to make it do so.
  #
  def collection_filter_sort_by_mills(object)
    # Ransack simply ignores the sort param if it doesn't determine it to be
    # "ransortable", so we'll just look at the param and apply an order to
    # the relation directly if it's "mill"
    if params[:q] && sort = params[:q][:s] 
      if sort =~ /mill (asc|desc)/
        object = object.order("mills.name #{$1}")
      end
    end

    object
  end

  def method_for_build
    :new_as_admin
  end

  def method_for_association_chain
    :meta_users
  end

  def create_resource(object)
    object.invited_by = current_user
    object.save
  end
end
