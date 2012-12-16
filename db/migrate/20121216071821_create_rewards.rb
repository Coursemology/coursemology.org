class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.string :icon_url
      t.string :title
      t.string :description
      t.integer :creator_id
      t.integer :course_id

      t.timestamps
    end
  end
end
