class AddTTypeToTrainings < ActiveRecord::Migration
  def change
    add_column :trainings, :t_type, :integer, default: 1
  end
end
