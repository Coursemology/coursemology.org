class UserReward < ActiveRecord::Base
  attr_accessible :claimed_at, :reward_id, :user_id

  belongs_to :user
  belongs_to :reward
end
