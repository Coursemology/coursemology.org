class CreateSurveySubmissions < ActiveRecord::Migration
  def change
    create_table :survey_submissions do |t|
      t.integer   :user_course_id
      t.integer   :survey_id
      t.datetime  :open_at
      t.datetime  :submitted_at
      t.string    :status

      t.time      :deleted_at
      t.timestamps
    end

    add_index :survey_submissions, :user_course_id
    add_index :survey_submissions, :survey_id
  end
end
