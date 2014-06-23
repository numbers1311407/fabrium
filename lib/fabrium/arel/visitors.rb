require 'arel/visitors'

module Arel
  module Visitors
    class ToSql
      def visit_Range o, a
        visit [visit(o.begin, a), visit(o.end, a)], a
      end
    end

    class PostgreSQL
      def visit_Arel_Nodes_Overlaps o, a
        a = o.left if ::Arel::Attributes::Attribute === o.left

        # the available range types
        range_types = %w(
          int4range
          int8range
          numrange
          daterange
          tsrange
          tstzrange
        )

        # the sql_type also serves as the function call to return the
        # overlapping range for the query, e.g.
        #
        #     model.range_value && int4range(1, 2, '[]')
        #
        sql_type = a.relation.engine.columns_hash[a.name.to_s].sql_type

        # if the right value isn't a range or this column is not a range
        # type, nullify the query
        unless o.right.is_a?(Range) && range_types.member?(sql_type)
          return "1=0"
        end

        # pg supports (and defaults to in the case of overlap) exlusive 
        # lower bounded ranges, but ruby does not.  It's either inclusive 
        # ends or exclusive upper bound
        bounds = o.right.exclude_end? ? "[)" : "[]"

        "#{visit o.left, a} #{o.operator} " +
            "#{sql_type}(#{visit o.right, a}, '#{bounds}')"
      end

      def visit_Arel_Nodes_Contains o, a
        a = o.left if ::Arel::Attributes::Attribute === o.left
        sql_type = a.relation.engine.columns_hash[a.name.to_s].sql_type
        o.right = o.right.to_f if sql_type == 'numrange'
        "#{visit o.left, a} #{o.operator} #{visit o.right, a}"
      end
    end
  end
end
