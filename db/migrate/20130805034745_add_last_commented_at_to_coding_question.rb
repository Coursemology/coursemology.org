class AddLastCommentedAtToCodingQuestion < ActiveRecord::Migration
  def change
    add_column :coding_questions, :last_commented_at, :time
  end
end
