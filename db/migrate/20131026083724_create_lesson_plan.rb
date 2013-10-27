class CreateLessonPlan < ActiveRecord::Migration
  def change
    create_table :lesson_plan_entries do |t|
      t.integer    :course_id
      t.integer    :creator_id
      t.string     :title
      t.integer    :type
      t.text       :description
      t.datetime   :start_at
      t.datetime   :end_at
      t.string     :location
    end

    create_table :lesson_plan_milestones do |t|
      t.integer    :course_id
      t.integer    :creator_id
      t.string     :title
      t.text       :description
      t.datetime   :end_at
    end

    create_table :lesson_plan_resources do |t|
      t.integer    :lesson_plan_entry_id
      t.integer    :obj_id
      t.string     :obj_type
    end
  end
end
