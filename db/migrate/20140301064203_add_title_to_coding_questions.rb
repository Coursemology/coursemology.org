class AddTitleToCodingQuestions < ActiveRecord::Migration
  def change
    rename_column :coding_questions, :step_name, :title
  end
end
