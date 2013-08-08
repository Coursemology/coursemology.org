class AddLastCommentedAtToMcq < ActiveRecord::Migration
  def change
    add_column :mcqs, :last_commented_at, :time
  end
end
