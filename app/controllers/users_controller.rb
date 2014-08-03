class UsersController < ResourceController
  self.default_sort = {name: 'email', dir: 'asc'}

  permit_params [
    :email,
    :pending,
    :wants_email,
    :admin
  ]

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

    respond_with(resource) do |wants|
      wants.js
    end
  end

  protected

  def collection_filter_include_meta(object)
    object.includes(:meta)
  end

  def collection_filter_exclude_admins(object)
    object.where.not(meta_type: 'Admin')
  end
end
