class CreateTrainingSubmissions < ActiveRecord::Migration
  def change
    create_table :training_submissions do |t|
      t.integer :student_id
      t.integer :training_id
      t.integer :current_step
      t.datetime :open_at
      t.datetime :submit_at

      t.timestamps
    end
  end
end
