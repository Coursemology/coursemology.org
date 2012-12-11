class CreateAnswerGradings < ActiveRecord::Migration
  def change
    create_table :answer_gradings do |t|
      t.integer :grader_id
      t.integer :grade
      t.string :comment
      t.integer :student_answer_id
      t.integer :submission_grading_id

      t.timestamps
    end
  end
end
