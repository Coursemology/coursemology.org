class AddIndexToTrainingSubmission < ActiveRecord::Migration
  def change
    add_index :training_submissions, :std_course_id
    add_index :training_submissions, :training_id
  end
end
