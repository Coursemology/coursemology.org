class RenameWrittenQuestionToQuestion < ActiveRecord::Migration
  def change
    rename_table :written_questions, :questions
  end
end
