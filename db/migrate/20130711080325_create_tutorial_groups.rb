class CreateTutorialGroups < ActiveRecord::Migration
  def change
    create_table :tutorial_groups do |t|
      t.integer :course_id
      t.integer :std_course_id
      t.integer :tut_course_id

      t.timestamps
    end
    add_index :tutorial_groups, [:std_course_id, :tut_course_id],unique: true
  end
end
