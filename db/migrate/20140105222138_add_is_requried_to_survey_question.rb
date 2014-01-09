class AddIsRequriedToSurveyQuestion < ActiveRecord::Migration
  def change
    add_column :survey_questions, :is_required, :boolean, default: true
  end
end
