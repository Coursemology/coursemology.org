class LessonPlanResource < ActiveRecord::Base
  attr_accessible :obj_id, :obj_type

  belongs_to :lesson_plan_entry
  belongs_to :obj, :polymorphic => true
end
