class ChangeDescriptionTextFormatInCodingQuestions < ActiveRecord::Migration
  def up
    change_column :coding_questions, :description, :text
  end

  def down
    change_column :coding_questions, :description, :string
  end
end
