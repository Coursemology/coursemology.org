class AddMaterialsTimestamps < ActiveRecord::Migration
  def change
    change_table :material_folders do |t|
      t.timestamps
    end
    change_table :materials do |t|
      t.timestamps
    end
  end
end
