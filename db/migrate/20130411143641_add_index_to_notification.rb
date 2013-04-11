class AddIndexToNotification < ActiveRecord::Migration
  def change
    add_index :notifications, :target_course_id
    add_index :notifications, :actor_course_id
  end
end
