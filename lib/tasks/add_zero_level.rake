namespace :db do
  task add_zero_level: :environment do
    courses = Course.all
    courses.each do |course|
      unless course.levels.find_by_level(0)
        level = course.levels.build({ level: 0, exp_threshold: 0 })
        level.save
      end
    end
  end
end
