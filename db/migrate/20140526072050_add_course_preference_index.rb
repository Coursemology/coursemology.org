class AddCoursePreferenceIndex < ActiveRecord::Migration

  def up
    add_index :course_preferences, [:course_id, :preferable_item_id], unique: true
  end

  def down
    remove_index :course_preferences, [:course_id, :preferable_item_id]
  end
end
