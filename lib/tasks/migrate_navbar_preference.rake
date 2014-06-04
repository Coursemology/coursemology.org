namespace :db do
  desc "migrate navbar preferences"

  task migrate_navbar_preference: :environment do
    Course.all.each do |course|
      course.populate_preference
      items = ['announcements','missions', 'trainings', 'submissions', 'achievements', 'leaderboard', 'students', 'surveys', 'materials', 'lesson_plan', 'forums', 'comments']

      items.each do |tab|
        old_item = course.student_sidebar_items.where("preferable_items.name = '#{tab}'").first
        cnp = course.course_navbar_preferences.find_by_item(tab)
        cnp.name = old_item.prefer_value
        cnp.is_enabled = old_item.display
        cnp.is_displayed = old_item.display
        cnp.save
      end
    end
  end
end
