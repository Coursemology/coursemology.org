class AddIndexToCourseThemeAtt < ActiveRecord::Migration
  def change
    add_index :course_theme_attributes, :course_id
  end
end
