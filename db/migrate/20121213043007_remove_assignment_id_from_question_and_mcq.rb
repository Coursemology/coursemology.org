class RemoveAssignmentIdFromQuestionAndMcq < ActiveRecord::Migration
  def change
    remove_column :questions, :assignment_id
    remove_column :mcqs, :assignment_id
  end
end
