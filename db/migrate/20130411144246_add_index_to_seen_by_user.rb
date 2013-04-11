class AddIndexToSeenByUser < ActiveRecord::Migration
  def change
    add_index :seen_by_users, :user_course_id
    add_index :seen_by_users, :obj_id
  end
end
