class AddIndexToUserCourse < ActiveRecord::Migration
  def change
    add_index :user_courses, :user_id
    add_index :user_courses, :course_id
    add_index :user_courses, :role_id
    add_index :user_courses, :level_id
  end
end
