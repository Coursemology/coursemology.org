class RenameLessonPlanReservedColumnName < ActiveRecord::Migration
  def change
    rename_column :lesson_plan_entries, :type, :entry_type
  end
end
