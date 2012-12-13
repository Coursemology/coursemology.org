class CreateStdMcqAnswers < ActiveRecord::Migration
  def change
    create_table :std_mcq_answers do |t|
      t.integer :mcq_answer_id
      t.string :choices
      t.integer :student_id
      t.integer :mcq_id

      t.timestamps
    end
  end
end
