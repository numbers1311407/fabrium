require 'fabrium/arel/nodes'

module ActiveRecord
  module QueryMethods
    class WhereChain
      def overlaps(opts)
        apply_each_predicate opts, :overlaps
      end

      def contains(opts)
        apply_each_predicate opts, :contains
      end

      private

      def arel_table
        @scope.engine.arel_table
      end

      def apply_each_predicate opts, predicate
        opts.each do |key, val|
          @scope = @scope.where(arel_table[key].send(predicate, val))
        end

        @scope
      end
    end
  end
end
