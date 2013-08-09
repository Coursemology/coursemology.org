class RenameCommentsToStaffCommentsInCodingQuestions < ActiveRecord::Migration
  def up
    rename_column :coding_questions, :comments, :staff_comments
  end

  def down
  end
end
