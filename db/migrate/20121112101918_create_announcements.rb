class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.integer :creator_id
      t.integer :course_id
      t.datetime :publish_at
      t.integer :important

      t.timestamps
    end
  end
end
