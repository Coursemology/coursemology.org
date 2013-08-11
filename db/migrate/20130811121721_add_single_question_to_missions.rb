class AddSingleQuestionToMissions < ActiveRecord::Migration
  def change
    add_column :missions, :single_question, :boolean, default: false
  end
end
