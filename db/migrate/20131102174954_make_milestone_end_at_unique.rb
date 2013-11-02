class MakeMilestoneEndAtUnique < ActiveRecord::Migration
  def change
    add_index :lesson_plan_milestones, [:course_id, :end_at], { unique: true }
  end
end
