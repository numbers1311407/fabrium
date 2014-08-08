class UsersController < ResourceController
  self.default_sort = {name: 'email', dir: 'asc'}

  permit_params [
    :email,
    :pending,
    :wants_email,
    :admin
  ]

  has_scope :mill do |controller, scope, value|
    scope.mills.where(meta_id: value)
  end

  has_scope :scope do |controller, scope, value|
    case value
    when 'pending' then scope = scope.pending
    when 'mill'    then scope = scope.mills
    when 'buyer'   then scope = scope.buyers
    when 'admin'   then scope = scope.admins
    end

    scope
  end

  # eager load the metas
  add_collection_filter_scope :collection_filter_include_meta

  # Admin users are managed elsewhere.  This HTML index is mostly here
  # for approving pending users.
  add_collection_filter_scope :collection_filter_exclude_admins

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

  helper_method :scope_options

  # non admins are scoped to their users (mills, basically, as buyers
  # only have one user and should not have admin access to this page)
  def begin_of_association_chain
    unless current_user.is_admin?
      current_user.meta
    end
  end

  def scope_options
    scopes = %w(pending mill buyer)
  end

  def collection_filter_include_meta(object)
    object.includes(:meta)
  end

  def collection_filter_exclude_admins(object)
    object.where.not(meta_type: 'Admin')
  end
end
