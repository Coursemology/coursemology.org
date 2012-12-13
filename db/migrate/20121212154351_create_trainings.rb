class CreateTrainings < ActiveRecord::Migration
  def change
    create_table :trainings do |t|
      t.integer :course_id
      t.integer :creator_id
      t.string :title
      t.string :description
      t.integer :exp
      t.datetime :open_at
      t.integer :order

      t.timestamps
    end
  end
end
