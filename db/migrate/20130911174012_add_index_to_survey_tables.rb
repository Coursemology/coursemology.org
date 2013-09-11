class AddIndexToSurveyTables < ActiveRecord::Migration
  def change

    add_index :surveys, :course_id
    add_index :survey_sections, :survey_id
    add_index :survey_questions, :survey_id
    add_index :survey_questions, :survey_section_id
    add_index :survey_question_options, :question_id
    add_index :survey_mrq_answers , :user_course_id
    add_index :survey_mrq_answers , :question_id

  end
end
