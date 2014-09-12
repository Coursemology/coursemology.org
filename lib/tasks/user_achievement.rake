namespace :user_achievement do
  desc "set obtain date to submitted date or create_at"
  task :set_obtain_date => :environment do
    UserAchievement.all.each do |uach|
      uach.assign_obtained_date
      uach.obtained_at ||= uach.created_at
      uach.save
    end
  end
end
