class AddIndexToAnswerGrading < ActiveRecord::Migration
  def change
    add_index :answer_gradings, :grader_id
    add_index :answer_gradings, :student_answer_id
    add_index :answer_gradings, :submission_grading_id
  end
end
