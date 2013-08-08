class AddColumnsToMcqToSupportAllAnswersKind < ActiveRecord::Migration
  def change
    add_column :mcqs, :correct_answers, :text
    add_column :mcqs, :select_all, :boolean
  end
end
