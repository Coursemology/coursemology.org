class CreateTitles < ActiveRecord::Migration
  def change
    create_table :titles do |t|
      t.string :title
      t.string :description
      t.integer :creator_id
      t.integer :course_id

      t.timestamps
    end
  end
end
