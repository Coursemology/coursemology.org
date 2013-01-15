class CreateStdTags < ActiveRecord::Migration
  def change
    create_table :std_tags do |t|
      t.integer :std_course_id
      t.integer :tag_id
      t.integer :exp

      t.timestamps
    end
  end
end
