require 'arel/visitors'

module Arel
  module Visitors
    class ToSql
      def visit_Range o, a
        visit [visit(o.begin, a), visit(o.end, a)], a
      end
    end

    class PostgreSQL
      # the available range types
      RANGE_TYPES = %w(
        int4range
        int8range
        numrange
        daterange
        tsrange
        tstzrange
      ).freeze

      def visit_Arel_Nodes_Overlaps o, a
        a = o.left if ::Arel::Attributes::Attribute === o.left

        # the sql_type also serves as the function call to return the
        # overlapping range for the query, e.g.
        #
        #     model.range_value && int4range(1, 2, '[]')
        #
        sql_type = a.relation.engine.columns_hash[a.name.to_s].sql_type

        if o.right.is_a?(Range) && RANGE_TYPES.member?(sql_type)
          # pg supports (and defaults to in the case of overlap) exlusive 
          # lower bounded ranges, but ruby does not.  It's either inclusive 
          # ends or exclusive upper bound
          bounds = o.right.exclude_end? ? "[)" : "[]"

          "#{visit o.left, a} #{o.operator} " +
              "#{sql_type}(#{visit o.right, a}, '#{bounds}')"

        else
          "#{visit o.left, a} #{o.operator} ARRAY[#{visit o.right, a}]"
        end
      end

      def visit_Arel_Nodes_Contains o, a
        a = o.left if ::Arel::Attributes::Attribute === o.left
        column = a.relation.engine.columns_hash[a.name.to_s]
        o.right = o.right.to_f if column.sql_type == 'numrange'

        fmt = column.array ? "%s %s ARRAY[%s]" : "%s %s %s"
        out = fmt % [visit(o.left, a), o.operator, visit(o.right, a)]
        out
      end
    end
  end
end
