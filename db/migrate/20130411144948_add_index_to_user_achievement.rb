class AddIndexToUserAchievement < ActiveRecord::Migration
  def change
    add_index :user_achievements, :user_course_id
    add_index :user_achievements, :achievement_id
  end
end
