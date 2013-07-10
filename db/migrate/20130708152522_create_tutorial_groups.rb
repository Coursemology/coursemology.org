class CreateTutorialGroups < ActiveRecord::Migration
  def change
    create_table :tutorial_groups do |t|
      t.integer :course_id
      t.integer :tutor_id
      t.integer :student_id

      t.timestamps
    end
  end
end
