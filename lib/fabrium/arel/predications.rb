require 'fabrium/arel/nodes'
require 'arel/predications'

module Arel
  module Predications
    def overlaps(other)
      Nodes::Overlaps.new self, other
    end

    def contains(other)
      Nodes::Contains.new self, other
    end
  end
end
