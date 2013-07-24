class AddLastCommentedAtToStdCodingAnswers < ActiveRecord::Migration
  def change
    add_column :std_coding_answers, :last_commented_at, :time
  end
end
