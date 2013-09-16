class CreateSurveyQuestionOptions < ActiveRecord::Migration
  def change
    create_table :survey_question_options do |t|
      t.integer   :question_id
      t.text      :description

      t.time      :deleted_at
      t.timestamps
    end
  end
end
