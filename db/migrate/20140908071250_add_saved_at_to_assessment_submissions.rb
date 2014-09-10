class AddSavedAtToAssessmentSubmissions < ActiveRecord::Migration
  def change
    add_column :assessment_submissions, :saved_at, :datetime
  end
end
