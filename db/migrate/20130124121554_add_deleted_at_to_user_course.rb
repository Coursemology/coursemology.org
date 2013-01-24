class AddDeletedAtToUserCourse < ActiveRecord::Migration
  def change
    add_column :user_courses, :deleted_at, :time
  end
end
