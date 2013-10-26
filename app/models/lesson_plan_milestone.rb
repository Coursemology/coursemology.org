class LessonPlanMilestone < ActiveRecord::Base
  attr_accessible

  belongs_to :course
  belongs_to :creator, class_name: "User"
end
