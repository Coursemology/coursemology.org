class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.integer :student_id
      t.integer :assignment_id
      t.datetime :open_at
      t.datetime :submit_at
      t.integer :attempt

      t.timestamps
    end
  end
end
