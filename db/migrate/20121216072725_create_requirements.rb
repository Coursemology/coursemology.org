class CreateRequirements < ActiveRecord::Migration
  def change
    create_table :requirements do |t|
      t.integer :req_id
      t.string :req_type
      t.integer :obj_id
      t.string :obj_type

      t.timestamps
    end
  end
end
