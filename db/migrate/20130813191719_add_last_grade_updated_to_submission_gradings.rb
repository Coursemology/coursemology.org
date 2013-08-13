class AddLastGradeUpdatedToSubmissionGradings < ActiveRecord::Migration
  def change
    add_column :submission_gradings, :last_grade_updated, :datetime
  end
end
