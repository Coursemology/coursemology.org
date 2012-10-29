class ChangeAssignmentColumnCourse < ActiveRecord::Migration
  def change
    rename_column :assignments, :class_id, :course_id
  end
end
