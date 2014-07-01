namespace :db do
  desc 'Migrates assessments to the new schema in 20140527151234_assessment_redesign.rb'

  task migrate_assessments: :environment do
    Mission.all.each do |m|
      puts m.to_yaml
    end
  end
end
