class AddIndexToSubmission < ActiveRecord::Migration
  def change
    add_index :submissions, :std_course_id
    add_index :submissions, :mission_id
    add_index :submissions, :final_grading_id
  end
end
