class AddUniqIndexToUserCourses < ActiveRecord::Migration
  def change
    add_index :user_courses, [:user_id, :course_id], unique: true
    remove_column :user_courses, :deleted_at
  end
end
