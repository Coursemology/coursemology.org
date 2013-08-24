class AddNameToUserCourses < ActiveRecord::Migration
  def change
    add_column :user_courses, :name, :string

    UserCourse.all.each do |uc|
      uc.name = uc.user.name
      uc.save
    end
  end
end
