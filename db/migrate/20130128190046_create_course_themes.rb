class CreateCourseThemes < ActiveRecord::Migration
  def change
    create_table :course_themes do |t|
      t.integer :course_id
      t.integer :theme_id
      t.string :theme_folder_url

      t.timestamps
    end
  end
end
