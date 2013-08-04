namespace :db do
  desc "populate existing courses with preference"

  task populate_course_pref: :environment do
    Course.all.each do |c|
      c.populate_preference
    end
  end
end