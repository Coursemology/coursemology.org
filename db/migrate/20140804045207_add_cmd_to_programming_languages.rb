class AddCmdToProgrammingLanguages < ActiveRecord::Migration
  def change
    add_column :programming_languages, :cmd, :string
  end
end
