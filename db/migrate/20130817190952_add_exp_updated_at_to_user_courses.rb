class AddExpUpdatedAtToUserCourses < ActiveRecord::Migration
  def change
    add_column :user_courses, :exp_updated_at, :timestamp

    UserCourse.all.each do |uc|
      uc.exp_updated_at = uc.updated_at
      uc.save
    end
  end
end
