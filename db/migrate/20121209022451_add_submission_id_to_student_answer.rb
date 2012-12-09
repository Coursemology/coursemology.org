class AddSubmissionIdToStudentAnswer < ActiveRecord::Migration
  def change
    add_column :student_answers, :submission_id, :integer
  end
end
