class AddLastActiveTimeToUserCourses < ActiveRecord::Migration
  def change
    add_column :user_courses, :last_active_time, :datetime
  end
end
