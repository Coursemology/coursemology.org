class ChangeAssignmentToMission < ActiveRecord::Migration
  def change
    rename_table :assignments, :missions
    rename_column :submissions, :assignment_id, :mission_id
  end
end
