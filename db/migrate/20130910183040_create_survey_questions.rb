class CreateSurveyQuestions < ActiveRecord::Migration
  def change
    create_table :survey_questions do |t|
      t.integer     :type_id
      t.integer     :survey_id
      t.integer     :survey_section_id
      t.text        :description
      t.boolean     :publish, default: true
      t.integer     :max_response
      t.integer     :pos

      t.time        :deleted_at
      t.timestamps
    end
  end
end
