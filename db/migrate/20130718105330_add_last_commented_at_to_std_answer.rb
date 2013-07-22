class AddLastCommentedAtToStdAnswer < ActiveRecord::Migration
  def change
    add_column :std_answers, :last_commented_at, :time
  end
end
