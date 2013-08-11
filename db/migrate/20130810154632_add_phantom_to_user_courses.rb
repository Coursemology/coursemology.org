class AddPhantomToUserCourses < ActiveRecord::Migration
  def change
    add_column :user_courses, :is_phantom, :boolean, default: false
  end
end
