class AddObtainedAtToUserAchievement < ActiveRecord::Migration
  def change
    add_column :user_achievements, :obtained_at, :datetime
  end
end
