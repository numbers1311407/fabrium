module FabricVariants
  module Image
    extend ActiveSupport::Concern

    IMAGE_SIZE = 200

    included do
      dragonfly_accessor :image

      validates_presence_of :image_name
      validates_presence_of :image_crop, if: :should_validate_crop?
    end

    def perfect_size?
      image_stored? && (image_width == IMAGE_SIZE && image_height == IMAGE_SIZE)
    end

    def thumb
      if image_crop.present?
        resize, crop = image_crop.split(';')
        image.thumb(resize).thumb(crop)
      else 
        image
      end
    end

    def thumb_path
      image_stored? ? thumb.url : nil
    end

    def image_path
      image_stored? ? image.url : nil
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
