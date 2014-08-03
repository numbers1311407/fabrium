class FabricNotesController < ResourceController
  defaults finder: :find_by_fabric_id!

  # WARNING: it's critical that `id` is not permitted.  not that it normaly
  # is, but in this case it would actually wreak havoc as the `id` passed
  # is the fabric id, but ends up injected into the `fabric_note` params.
  permit_params :note

  def update
    # Poor man's find_or_create_by_fabric_id
    begin
      object = resource
    rescue ActiveRecord::RecordNotFound
      object = build_resource
      object.save
    end

    update!
  end

  protected

  def begin_of_association_chain
    current_user
  end

  # This controller should only respond to show, update, delete.  If
  # there's no `id` param there is no scope.  Note that this scope is
  # only really for the *creation* of new records to change the scope
  # to be notes for the given Fabric ID.  The *finder* is handled
  # above.
  #
  # Could change it, but it's not the prettiest thing with how
  # inherited_resources works.  Seems fine.
  #
  def apply_scopes(target)
    if params[:id]
      target.where(fabric_id: params[:id])
    else
      target.none
    end
  end
end
