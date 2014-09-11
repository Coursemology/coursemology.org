namespace :user_achievement do
  desc "set obtain date to create_at"
  task :set_obtain_date => :environment do
    UserAchievement.all.each do |uach|
      uach.obtained_at ||= uach.created_at
      uach.save
    end
  end

end
