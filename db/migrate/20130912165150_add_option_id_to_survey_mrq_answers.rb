class AddOptionIdToSurveyMrqAnswers < ActiveRecord::Migration
  def change
    add_column :survey_mrq_answers, :option_id, :integer

    SurveyMrqAnswer.where("selected_options is NULL").destroy_all
    to_delete = []
    SurveyMrqAnswer.all.each do |answer|
      to_delete << answer
      answer.options.each do |option|
        SurveyMrqAnswer.create! option_id: option.id,
                                user_course_id: answer.user_course_id,
                                question_id: answer.question_id
      end
    end
    to_delete.map {|answer| answer.destroy }
  end
end
