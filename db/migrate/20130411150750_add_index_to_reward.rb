class AddIndexToReward < ActiveRecord::Migration
  def change
    add_index :rewards, :creator_id
    add_index :rewards, :course_id
  end
end
