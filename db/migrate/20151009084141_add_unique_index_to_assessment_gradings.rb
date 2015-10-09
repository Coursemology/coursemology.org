class AddUniqueIndexToAssessmentGradings < ActiveRecord::Migration
  def change
    add_index :assessment_gradings, :submission_id, unique: true
  end
end
