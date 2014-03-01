class AddTitleToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :title, :string
  end
end
