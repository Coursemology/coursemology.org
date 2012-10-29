class CreateStudentAnswers < ActiveRecord::Migration
  def change
    create_table :student_answers do |t|
      t.integer :answer_id
      t.datetime :started_at
      t.datetime :submitted_at
      t.string :note

      t.timestamps
    end
  end
end
