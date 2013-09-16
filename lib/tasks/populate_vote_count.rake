namespace :db do
  desc "Populate survey question option count after migration"

  task populate_vote_count: :environment do
    SurveyQuestionOption.all.each do |option|
      option.count = option.answers.count
      option.save
    end
  end
end
