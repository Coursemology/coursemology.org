class CreateLevels < ActiveRecord::Migration
  def change
    create_table :levels do |t|
      t.integer :level
      t.integer :exp_threshold
      t.integer :course_id
      t.integer :creator_id

      t.timestamps
    end
  end
end
