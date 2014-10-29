module Mills::FilteredDomains
  extend ActiveSupport::Concern

  included do
    enum domain_filter: [:blacklist, :whitelist]

    # validates :domain_names, presence: true, if: :whitelist?
  end

  module ClassMethods
    def filter_by_domain(domain)
      where domain_blacklist_conditions(domain).
              or(domain_whitelist_conditions(domain))
    end

    # Condition for "blacklisting" domains, which is the default.
    # Only domains that *are* in the domain list will be rejected.  All
    # other mills will come through.
    def domain_blacklist_conditions(domain)
      arel_table[:domain_filter].eq(domain_filters[:blacklist]).and(
        arel_table[:domains].contains(domain).not
      )
    end

    # Condition for "whitelisting" domains.
    # Only domains that *are NOT* in the domain list will be accepted.
    # This is the opt-in setting as it's much more restrictive
    def domain_whitelist_conditions(domain)
      arel_table[:domain_filter].eq(domain_filters[:whitelist]).and(
        arel_table[:domains].contains(domain)
      )
    end
  end

  def domain_names
    domains.join(",");
  end

  def domain_names=(str)
    self.domains = str.split(",")
  end
end
