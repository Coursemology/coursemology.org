class AddIndexToStdTag < ActiveRecord::Migration
  def change
    add_index :std_tags, :std_course_id
    add_index :std_tags, :tag_id
  end
end
