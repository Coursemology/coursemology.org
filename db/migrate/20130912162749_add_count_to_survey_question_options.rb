class AddCountToSurveyQuestionOptions < ActiveRecord::Migration
  def change
    add_column :survey_question_options, :count, :integer
  end
end
