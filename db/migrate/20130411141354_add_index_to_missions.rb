class AddIndexToMissions < ActiveRecord::Migration
  def change
    add_index :missions, :course_id
  end
end
