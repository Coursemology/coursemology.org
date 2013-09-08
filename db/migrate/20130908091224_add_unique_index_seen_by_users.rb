class AddUniqueIndexSeenByUsers < ActiveRecord::Migration
  def change

    remove_index :seen_by_users, [:obj_id, :obj_type]
    remove_index :seen_by_users, [:user_course_id, :obj_type]
    add_index :seen_by_users, [:obj_id, :obj_type]
    add_index :seen_by_users, [:user_course_id, :obj_type]
    add_index :seen_by_users, [:user_course_id, :obj_id, :obj_type], :unique => true
  end

end
