class RemoveLessonPlanIndex < ActiveRecord::Migration
  def up
   remove_index :lesson_plan_milestones, :column =>[:course_id, :end_at]
  end

  def down
  end
end
