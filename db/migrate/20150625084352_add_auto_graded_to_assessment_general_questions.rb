class AddAutoGradedToAssessmentGeneralQuestions < ActiveRecord::Migration
  def change
    add_column :assessment_general_questions, :auto_graded, :boolean
    add_column :assessment_general_questions, :auto_grading_type_cd, :integer, default: 0
  end
end
