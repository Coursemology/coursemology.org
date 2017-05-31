class ChangeSystemAnnouncementType < ActiveRecord::Migration
  def up
    change_column :system_wide_announcements, :body, :text
  end

  def down
  end
end
