class AddFinalGradingToQuizSubmission < ActiveRecord::Migration
  def change
    add_column :quiz_submissions, :final_grading_id, :integer
  end
end
