namespace :db do
  desc "populate existing courses with preference"

  task assign_achievements: :environment do
    new_ach = true
    while new_ach do
      puts "Have new achievment? ", new_ach
      new_ach = false
      UserCourse.all.each do |uc|
        if uc.is_student?
          puts uc.to_json
          uc.course.achievements.each do |ach|
            check = uc.check_achievement(ach, false)
            new_ach ||= check
            if check
              puts "new ach: ", uc.to_json, ach.to_json
              puts UserAchievement.count
            end
          end
        end
      end
    end
  end
end
