namespace :db do
  desc "fill existing achievements with pos"

  task fill_achievement_pos: :environment do
    Course.all.each do |c|
      c.fill_achievement_pos
    end
  end
end
