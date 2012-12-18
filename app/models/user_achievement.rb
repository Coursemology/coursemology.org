class UserAchievement < ActiveRecord::Base
  attr_accessible :achievement_id, :user_course_id

  belongs_to :user_course
  belongs_to :achievement
end
