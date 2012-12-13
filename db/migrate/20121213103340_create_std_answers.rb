class CreateStdAnswers < ActiveRecord::Migration
  def change
    create_table :std_answers do |t|
      t.string :text
      t.integer :student_id
      t.integer :question_id

      t.timestamps
    end
  end
end
