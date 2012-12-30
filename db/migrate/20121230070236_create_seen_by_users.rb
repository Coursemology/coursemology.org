class CreateSeenByUsers < ActiveRecord::Migration
  def change
    create_table :seen_by_users do |t|
      t.integer :user_course_id
      t.integer :obj_id
      t.string :obj_type

      t.timestamps
    end
  end
end
