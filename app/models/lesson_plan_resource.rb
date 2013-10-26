class LessonPlanResource < ActiveRecord::Base
  attr_accessible

  belongs_to :lesson_plan_entry
  belongs_to :obj, :polymorphic => true
end
