class AddIndexToStdAnswer < ActiveRecord::Migration
  def change
    add_index :std_answers, :student_id
    add_index :std_answers, :question_id
  end
end
