class CreateFabrics < ActiveRecord::Migration

  # As per the spec, the ID for Fabrics starts at 1001
  #
  # (Setting a start value for the pk seems to make more sense
  # than maintaining a separate, indexed, unique sequenced column)
  SEQ_START = 1001

  def change
    create_table :fabrics do |t|
      t.numrange :price_eu
      t.numrange :price_us
      t.integer :width, default: 0
      t.decimal :gsm, precision: 8, scale: 2, default: 0
      t.decimal :glm, precision: 8, scale: 2, default: 0
      t.decimal :osy, precision: 8, scale: 2, default: 0
      t.timestamps
    end

    reversible do |dir|
      dir.up { execute "ALTER SEQUENCE #{default_sequence_name(:fabrics)} RESTART #{SEQ_START}" }
    end
  end
end
