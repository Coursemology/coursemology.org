class AddUniqueIndexToUserAchievements < ActiveRecord::Migration
  def change
    remove_index  :user_achievements, [:achievement_id, :user_course_id]
    add_index     :user_achievements, [:user_course_id, :achievement_id], unique: true
  end
end
