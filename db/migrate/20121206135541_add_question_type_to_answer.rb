class AddQuestionTypeToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :question_type, :string
  end
end
