module FabricVariants

  module Color
    extend ActiveSupport::Concern

    ReHexColor = /[a-f0-9]{6}/

    SQL_JOIN_ALIAS = "fabric_variant_color_deltas"

    included do
      validates_presence_of :color
      validates_format_of :color, with: ReHexColor, allow_blank: true
    end

    def lab
      [cie_l, cie_a, cie_b].map(&:to_f)
    end

    def lab=(arr)
      self.cie_l, self.cie_a, self.cie_b = arr
    end

    def color=(hex="")
      hex = hex.downcase.sub(/^#/, '')
      self.lab = HexToLabConverter.new(hex).to_lab
      write_attribute(:color, hex)
    end

    def color
      HexToLabConverter.new(read_attribute(:color) || "")
    end

    module ClassMethods
      def near_color(hex, max_delta=nil)
        scoped = with_color_deltas(hex).reorder("#{SQL_JOIN_ALIAS}.delta ASC")
        scoped = scoped.where(["#{SQL_JOIN_ALIAS}.delta < ?", max_delta]) if max_delta.present?
        scoped
      end

      def with_color_deltas(hex)
        # Older version actually did a subselect of the whole table, honestly
        # not sure which one is faster as I don't know enough about pg.
        # Essentially the older select looked like
        #
        #     SELECT * from (         
        #       SELECT *, delta from fabric_variants
        #     ) fabric_variants ...
        #
        # And the newer version looks like
        #
        #     SELECT * from fabric_variants
        #     JOINS (
        #       SELECT id, delta from fabric_variants
        #     ) deltas 
        #     ON deltas.id = fabric_variants.id ...
        #
        # The join version *feels* better but that is 100% unsubstantiated.
        # It seems like it'd be faster to somehow limit the subquery by
        # the conditions on the main query, but if that can be done I couldn't
        # figure out how to do it.
        #
        # # old invocation
        # from(color_delta_subselect(hex))
        #
        table_alias = color_delta_subselect(hex)
        joins("JOIN #{table_alias.to_sql} ON #{SQL_JOIN_ALIAS}.id = fabric_variants.id")
      end

      protected

      def color_delta_subselect(hex)
        lab = HexToLabConverter.new(hex).to_lab
        delta = sanitize_sql_array([
          "(|/((cie_l-(?))^2+(cie_a-(?))^2+(cie_b-(?))^2)) delta", *lab
        ])
        unscoped.select("id, #{delta}").as(SQL_JOIN_ALIAS)
      end
    end

    private

    class HexToLabConverter < String
      def initialize(hex="")
        hex = hex.downcase.sub(/^#/, '')
        @valid = ReHexColor === hex
        super(hex)
      end

      def valid?
        @valid
      end

      def to_rgb
        return [0, 0, 0] unless valid?
        self.scan(/.{2}/).map {|v| v.hex.to_f }
      end

      def to_xyz
        return [0, 0, 0] unless valid?

        r, g, b = to_rgb.map do |v|
          v /= 255.0
          v = v > 0.04045 ? ((v + 0.055) / 1.055) ** 2.4 : v / 12.92
          v * 100
        end

        # Observer = 2°, Illuminant = D65
        x = r * 0.4124 + g * 0.3576 + b * 0.1805
        y = r * 0.2126 + g * 0.7152 + b * 0.0722
        z = r * 0.0193 + g * 0.1192 + b * 0.9505

        [x, y, z]
      end

      def to_lab
        return [0, 0, 0] unless valid?

        x, y, z = to_xyz

        # Observer = 2°, Illuminant= D65
        x = x / 95.047
        y = y / 100.000
        z = z / 108.883

        x, y, z = [x, y, z].map do |v|
          v > 0.008856 ? v ** (1.0/3) : (7.787 * v) + (16.0/116)
        end

        l = (116 * y) - 16
        a = 500 * (x - y)
        b = 200 * (y - z)

        [l, a, b]
      end
    end
  end
end
