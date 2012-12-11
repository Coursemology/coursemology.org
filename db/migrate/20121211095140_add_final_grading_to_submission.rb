class AddFinalGradingToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :final_grading_id, :integer
  end
end
