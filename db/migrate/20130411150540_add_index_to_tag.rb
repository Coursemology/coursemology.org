class AddIndexToTag < ActiveRecord::Migration
  def change
    add_index :tags, :course_id
    add_index :tags, :tag_group_id
  end
end
