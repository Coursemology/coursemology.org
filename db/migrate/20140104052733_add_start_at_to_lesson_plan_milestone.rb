class AddStartAtToLessonPlanMilestone < ActiveRecord::Migration
  def change
  	add_column :lesson_plan_milestones, :start_at, :datetime
  end
end
