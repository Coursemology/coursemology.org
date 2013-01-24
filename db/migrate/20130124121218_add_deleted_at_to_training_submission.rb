class AddDeletedAtToTrainingSubmission < ActiveRecord::Migration
  def change
    add_column :training_submissions, :deleted_at, :time
  end
end
