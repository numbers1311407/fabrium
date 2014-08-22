class MakeFabricVariantDimensionsNumeric < ActiveRecord::Migration
  def up
    change_column :fabric_variants, :image_width, 'integer USING CAST(image_width AS integer)'
    change_column :fabric_variants, :image_height, 'integer USING CAST(image_height AS integer)'
  end


  def down
    change_column :fabric_variants, :image_width, 'string USING CAST(image_width AS string)'
    change_column :fabric_variants, :image_height, 'string USING CAST(image_height AS string)'
  end
end
