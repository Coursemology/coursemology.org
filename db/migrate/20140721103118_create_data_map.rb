class CreateDataMap < ActiveRecord::Migration
  def up
    create_table :data_maps do |t|
      t.string :data_type
      t.integer :old_data_id
      t.integer :new_data_id
    end
  end

  def down
    drop_table :data_maps
  end
end
