class CreateDuplicateLogs < ActiveRecord::Migration
  def change
    create_table :duplicate_logs do |t|
      t.integer :user_id
      t.integer :origin_course_id
      t.integer :dest_course_id
      t.integer :origin_obj_id
      t.string :origin_obj_type
      t.integer :dest_obj_id
      t.string :dest_obj_type

      t.timestamps
    end
  end
end
