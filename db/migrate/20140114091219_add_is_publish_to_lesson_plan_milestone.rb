class AddIsPublishToLessonPlanMilestone < ActiveRecord::Migration
  def change
    add_column :lesson_plan_milestones, :is_publish, :boolean, default: true
  end
end
