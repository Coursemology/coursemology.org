class AddTitleAndDescToAnnouncement < ActiveRecord::Migration
  def change
    add_column :announcements, :title, :string
    add_column :announcements, :description, :string
  end
end
