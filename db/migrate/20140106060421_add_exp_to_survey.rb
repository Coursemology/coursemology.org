class AddExpToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :exp, :integer
  end
end
