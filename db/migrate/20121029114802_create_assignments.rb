class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :class_id
      t.integer :exp
      t.datetime :open_at
      t.datetime :close_at
      t.datetime :deadline
      t.integer :timelimit
      t.integer :attempt_limit
      t.integer :auto_graded
      t.integer :order
      t.string :description
      t.integer :creator_id

      t.timestamps
    end
  end
end
