class AddPosToSurveyQuestionOptions < ActiveRecord::Migration
  def change
    add_column :survey_question_options, :pos, :integer
  end
end
