class AddStdCourseIdIndexToStdCodingAnswer < ActiveRecord::Migration
  def change
    add_index :std_coding_answers, :std_course_id
  end
end
