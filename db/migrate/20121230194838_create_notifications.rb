class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :target_course_id
      t.integer :actor_id
      t.integer :action_id
      t.integer :obj_id
      t.string :obj_type
      t.string :extra

      t.timestamps
    end
  end
end
