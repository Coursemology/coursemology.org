class CreateSystemWideAnnouncements < ActiveRecord::Migration
  def change
    create_table :system_wide_announcements do |t|
      t.references :creator
      t.string :subject
      t.string :body

      t.timestamps
    end
  end
end
