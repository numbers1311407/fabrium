require 'fabrium/active_record'
require 'fabrium/arel'

ActiveRecord::Base.send(:include, AttrLikeScope)
