class AddSubIdToSurveyAnswers < ActiveRecord::Migration
  def change
    add_column :survey_mrq_answers, :survey_submission_id, :integer
    add_column :survey_essay_answers, :survey_submission_id, :integer

    (SurveyEssayAnswer.all + SurveyMrqAnswer.all).each do |answer|
      unless answer.question
        next
      end
      answer.survey_submission = SurveySubmission.where(user_course_id: answer.user_course_id, survey_id: answer.question.survey_id).first
      answer.save
    end
  end
end
