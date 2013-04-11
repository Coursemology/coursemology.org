class AddIndexToCourseTheme < ActiveRecord::Migration
  def change
    add_index :course_themes, :course_id
    add_index :course_themes, :theme_id
  end
end
