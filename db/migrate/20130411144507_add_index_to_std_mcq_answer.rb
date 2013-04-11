class AddIndexToStdMcqAnswer < ActiveRecord::Migration
  def change
    add_index :std_mcq_answers, :mcq_answer_id
    add_index :std_mcq_answers, :student_id
    add_index :std_mcq_answers, :mcq_id
  end
end
