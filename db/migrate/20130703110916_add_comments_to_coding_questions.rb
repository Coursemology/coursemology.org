class AddCommentsToCodingQuestions < ActiveRecord::Migration
  def change
    add_column :coding_questions, :comments, :string
  end
end
