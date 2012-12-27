class AddExpTransactionIdToSubmissionGrading < ActiveRecord::Migration
  def change
    add_column :submission_gradings, :exp_transaction_id, :integer
  end
end
