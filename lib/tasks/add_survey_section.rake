namespace :db do
  task add_survey_section: :environment do
    Survey.where(is_contest: true).each do |s|
      qns = SurveyQuestion.where(survey_id: s.id)
      if s.sections.count == 0
        section = s.sections.create
      else
        section = s.sections.first
      end
      qns.each do |qn|
        qn.survey_section = section
        qn.save
      end
    end
  end
end