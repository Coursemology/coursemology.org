class ChangeStudentIdToStudentCourseIdInSbms < ActiveRecord::Migration
  def change
    rename_column :submissions, :student_id, :std_course_id
    rename_column :quiz_submissions, :student_id, :std_course_id
    rename_column :training_submissions, :student_id, :std_course_id
  end
end
