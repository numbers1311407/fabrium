require 'arel/nodes'

module Arel
  module Nodes
    class Overlaps < Arel::Nodes::Binary
      def operator; '&&' end
    end

    class Contains < Arel::Nodes::Binary
      def operator; '@>' end
    end
  end
end
