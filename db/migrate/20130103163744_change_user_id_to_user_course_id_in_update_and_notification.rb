class ChangeUserIdToUserCourseIdInUpdateAndNotification < ActiveRecord::Migration
  def change
    rename_column :activities, :actor_id, :actor_course_id
    rename_column :activities, :target_id, :target_course_id
    rename_column :notifications, :actor_id, :actor_course_id
  end
end
