class AddAchievementIdAndUserCourseIdIndexToUserAchievements < ActiveRecord::Migration
  def change
    add_index :user_achievements, [:achievement_id, :user_course_id]
  end
end
