class CreateCoursePreferences < ActiveRecord::Migration
  def change
    create_table :course_preferences do |t|
      t.integer :course_id
      t.integer :preferable_item_id
      t.string  :prefer_value
      t.boolean :display

      t.timestamps
    end

    add_index :course_preferences, :course_id
    add_index :course_preferences, :preferable_item_id
  end
end
