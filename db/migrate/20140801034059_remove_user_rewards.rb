class RemoveUserRewards < ActiveRecord::Migration
  def up
    drop_table :user_rewards
  end

  def down
  end
end
