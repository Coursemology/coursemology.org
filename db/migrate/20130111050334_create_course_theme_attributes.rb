class CreateCourseThemeAttributes < ActiveRecord::Migration
  def change
    create_table :course_theme_attributes do |t|
      t.integer :course_id
      t.integer :theme_attribute_id
      t.string :value

      t.timestamps
    end
  end
end
