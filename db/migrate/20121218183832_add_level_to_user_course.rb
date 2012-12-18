class AddLevelToUserCourse < ActiveRecord::Migration
  def change
    add_column :user_courses, :level_id, :integer
  end
end
