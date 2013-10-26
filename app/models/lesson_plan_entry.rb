class LessonPlanEntry < ActiveRecord::Base
  attr_accessible

  belongs_to :course
  belongs_to :creator, class_name: "User"
  has_many :resources, class_name: "LessonPlanResource"
end
