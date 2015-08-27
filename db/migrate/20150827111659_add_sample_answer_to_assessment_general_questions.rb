class AddSampleAnswerToAssessmentGeneralQuestions < ActiveRecord::Migration
  def change
    add_column :assessment_general_questions, :sample_answer, :text
  end
end
