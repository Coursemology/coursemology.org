class AddIndexToMission2 < ActiveRecord::Migration
  def change
    add_index :missions, :creator_id
  end
end
