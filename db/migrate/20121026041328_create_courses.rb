class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title
      t.integer :creator_id
      t.string :description

      t.timestamps
    end
  end
end
