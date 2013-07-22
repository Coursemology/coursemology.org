class AddStdCourseIdIndexToStdAnswer < ActiveRecord::Migration
  def change
    add_index :std_answers, :std_course_id
  end
end
