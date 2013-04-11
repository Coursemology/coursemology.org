class AddIndexToAchievement < ActiveRecord::Migration
  def change
    add_index :achievements, :creator_id
    add_index :achievements, :course_id
  end
end
