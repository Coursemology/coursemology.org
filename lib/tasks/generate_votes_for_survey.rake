namespace :db do
  desc "Generate votes for survey to test survey summary"

  task gen_survey_votes: :environment do
    UserCourse.all.each do |uc|
      Survey.all.each do |sv|
        sb = sv.survey_submissions.where(user_course_id:uc).first
        sb ||= sv.survey_submissions.build
        sb.user_course = uc
        sb.current_qn = sv.questions.count + 1
        sb.set_submitted
        sb.save
        sv.questions.each do |qn|
          options = qn.options
          selected_options = []
          (1..qn.max_response).each do |i|
            if rand(10) < 2
              selected_options <<  options[0,10].sample.id
            else
              selected_options <<  options.sample.id
            end
          end
          ans = qn.survey_mrq_answers.where(user_course_id: uc).first
          ans ||= qn.survey_mrq_answers.build
          ans.selected_options = selected_options.to_s
          ans.user_course = uc
          ans.save
        end
      end
    end
  end
end
