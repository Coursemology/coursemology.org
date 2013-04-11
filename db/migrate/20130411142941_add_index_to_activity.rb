class AddIndexToActivity < ActiveRecord::Migration
  def change
    add_index :activities, :course_id
  end
end
