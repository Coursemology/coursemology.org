class AddIndexToUserReward < ActiveRecord::Migration
  def change
    add_index :user_rewards, :user_course_id
    add_index :user_rewards, :reward_id
  end
end
