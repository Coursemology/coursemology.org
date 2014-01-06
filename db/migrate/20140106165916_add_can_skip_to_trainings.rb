class AddCanSkipToTrainings < ActiveRecord::Migration
  def change
    add_column :trainings, :can_skip, :boolean, default: false
  end
end
