class ChangeUserIdToUserCourseIdInGameTables < ActiveRecord::Migration
  def change
    rename_column :user_achievements, :user_id, :user_course_id
    rename_column :user_rewards, :user_id, :user_course_id
    rename_column :user_titles, :user_id, :user_course_id
  end
end
