class AddDependentIdToMissions < ActiveRecord::Migration
  def change
    add_column :missions, :dependent_id, :integer
  end
end
