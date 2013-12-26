class AddTabIdToTraining < ActiveRecord::Migration
  def change
    add_column :trainings, :tab_id, :integer
  end
end
