class AddIndexToSubmissionGrading < ActiveRecord::Migration
  def change
    add_index :submission_gradings, :grader_id
    add_index :submission_gradings, :sbm_id
    add_index :submission_gradings, :exp_transaction_id
  end
end
