class AddMultiplierToTrainingSubmission < ActiveRecord::Migration
  def change
    add_column :training_submissions, :multiplier, :float
  end
end
