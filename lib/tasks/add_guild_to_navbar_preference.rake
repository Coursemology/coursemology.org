namespace :db do
  task add_guild_to_navbar_preference: :environment do
    Course.all.each do |course|
      if course.course_navbar_preferences.count == 13
        pref = CourseNavbarPreference.create(item: 'guilds',
                                             name: 'Guilds',
                                             is_displayed: 0,
                                             is_enabled: 0,
                                             pos: 14)
        pref.course_id = course.id
        pref.navbar_preferable_item_id = 14
        pref.navbar_link_type_id = 1,
        pref.save
      end
    end
  end
end