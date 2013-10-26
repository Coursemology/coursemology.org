class LessonPlanEntry < ActiveRecord::Base
  attr_accessible :title, :entry_type, :description, :start_at, :end_at, :location

  belongs_to :course
  belongs_to :creator, class_name: "User"
  has_many :resources, class_name: "LessonPlanResource"

  # Defines all the types
  ENTRY_TYPES = [
    ['Lecture', 0],
    ['Recitation', 1],
    ['Tutorial', 2]
  ]
end
