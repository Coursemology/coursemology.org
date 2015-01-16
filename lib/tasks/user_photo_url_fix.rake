namespace :db do
  task user_profile_photo_fix: :environment do
    old_url = 'https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/c178.0.604.604/s160x160/252231_1002029915278_1941483569_n.jpg'
    new_url = 'http://coursemology.s3.amazonaws.com/public/default_profile_pic.png'

    User.all.each do |user|
      if user.profile_photo_url == old_url
        user.update_column(:profile_photo_url, new_url)
      end
    end
  end
end
