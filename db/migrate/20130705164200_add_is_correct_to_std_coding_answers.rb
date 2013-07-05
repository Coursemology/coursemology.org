class AddIsCorrectToStdCodingAnswers < ActiveRecord::Migration
  def change
    add_column :std_coding_answers, :is_correct, :boolean
  end
end
