class LessonPlanEntry < ActiveRecord::Base
  attr_accessible

  belongs_to :course
  belongs_to :creator, class_name: "User"
  has_many :resources, class_name: "LessonPlanResource"

  # Defines all the types
  TYPES = [
    ['Lecture', 0],
    ['Recitation', 1],
    ['Tutorial', 2]
  ]
end
