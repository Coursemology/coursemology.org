class AddTabIdToMission < ActiveRecord::Migration
  def change
    add_column :missions, :tab_id, :integer
  end
end
