class UserReward < ActiveRecord::Base
  attr_accessible :claimed_at, :reward_id, :user_course_id

  belongs_to :user_course
  belongs_to :reward
end
