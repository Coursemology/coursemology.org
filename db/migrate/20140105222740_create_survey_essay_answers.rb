class CreateSurveyEssayAnswers < ActiveRecord::Migration
  def change
    create_table :survey_essay_answers do |t|
      t.integer   :user_course_id
      t.integer   :question_id
      t.text      :text

      t.time      :deleted_at
      t.timestamps
    end
  end
end
