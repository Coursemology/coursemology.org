class AddStatusToTrainingSubmissions < ActiveRecord::Migration
  def change
    add_column :training_submissions, :status, :string
  end
end
