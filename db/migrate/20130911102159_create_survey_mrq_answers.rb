class CreateSurveyMrqAnswers < ActiveRecord::Migration
  def change
    create_table :survey_mrq_answers do |t|
      t.text      :selected_options
      t.integer   :user_course_id
      t.integer   :question_id

      t.time      :deleted_at
      t.timestamps
    end
  end
end
