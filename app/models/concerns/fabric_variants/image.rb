module FabricVariants
  module Image
    extend ActiveSupport::Concern

    THUMB_SIZE = 250

    included do
      dragonfly_accessor :image

      validates_presence_of :image_name
      validates_presence_of :image_crop, if: :should_validate_crop?
    end

    def perfect_size?
      image_stored? && (image_width == THUMB_SIZE && image_height == THUMB_SIZE)
    end

    def crop
      if image_crop.present?
        geometry = "%dx%d+%d+%d" % [
          image_crop[:w].round,
          image_crop[:w].round,
          image_crop[:x].round,
          image_crop[:y].round
        ]

        image.thumb(geometry)
      else 
        image
      end
    end

    def thumb
      crop.thumb("250x250") if image_stored?
    end

    def thumb_tiny
      crop.thumb("30x30") if image_stored?
    end

    def thumb_path
      thumb.url if image_stored?
    end

    def thumb_tiny_path
      thumb_tiny.url if image_stored?
    end

    def crop_path
      crop.url if image_stored?
    end

    def crop_width
      image_crop ? image_crop[:w] : 0
    end

    def crop_height
      image_crop ? image_crop[:w] : 0
    end

    def image_path
      image.url if image_stored?
    end

    def image_crop
      parsed = JSON.parse read_attribute(:image_crop)
      parsed.each {|k, v| parsed[k] = v.round }
      ActiveSupport::HashWithIndifferentAccess.new(parsed)
    rescue
      nil
    end

    def dominant_colors
      return [] unless image_stored?
      Miro::DominantColors.new(image.file).to_hex
    rescue
      []
    end

    protected

    def should_validate_crop?
      image.present? && !perfect_size?
    end
  end
end
