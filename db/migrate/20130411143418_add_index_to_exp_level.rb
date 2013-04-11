class AddIndexToExpLevel < ActiveRecord::Migration
  def change
    add_index :levels, :course_id
    add_index :levels, :creator_id
  end
end
