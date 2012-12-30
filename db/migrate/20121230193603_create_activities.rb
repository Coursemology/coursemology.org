class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :course_id
      t.integer :actor_id
      t.integer :target_id
      t.integer :action_id
      t.integer :obj_id
      t.string :obj_type
      t.string :extra

      t.timestamps
    end
  end
end
