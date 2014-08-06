class CleanupFabricVariantOrphansJob
  include SuckerPunch::Job

  #
  # During the fabric creation process it is possible to leave behind
  # orphan fabric variants, as the variants are created mid-form before
  # the fabric is saved.
  #
  # This job cleans up fabric variants with no parent fabric that are old
  # enough that it's unlikely anyone is still working with them mid-form.
  #

  STALE_AGE = 12.hours

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Rails.logger.info("CleanupFabricVariantOrphansJob starting")

      FabricVariant.orphans.
        where("created_at < ?", Time.now - STALE_AGE).delete_all
    end
  end
end
