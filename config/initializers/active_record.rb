require 'fabrium/active_record'
require 'fabrium/arel'

ActiveRecord::Base.send(:include, AttrLikeScope)

# Register `citext` to get rid of the OID warning in the logs
#
# Solution found here:
# http://gray.fm/2013/09/17/unknown-oid-with-rails-and-postgresql/
#
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.tap do |klass|
  klass::OID.register_type('citext', klass::OID::Identity.new)
end
