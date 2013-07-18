class AddStdCourseIdIndexToStdMcqAnswer < ActiveRecord::Migration
  def change
    add_index :std_mcq_answers, :std_course_id
  end
end
