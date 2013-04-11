class AddIndexToTitle < ActiveRecord::Migration
  def change
    add_index :titles, :creator_id
    add_index :titles, :course_id
  end
end
