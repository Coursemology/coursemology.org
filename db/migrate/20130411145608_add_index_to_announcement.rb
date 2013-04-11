class AddIndexToAnnouncement < ActiveRecord::Migration
  def change
    add_index :announcements, :creator_id
    add_index :announcements, :course_id
  end
end
