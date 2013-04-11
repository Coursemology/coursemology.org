class AddIndexToMcq < ActiveRecord::Migration
  def change
    add_index :mcqs, :creator_id
    add_index :mcqs, :correct_answer_id
  end
end
