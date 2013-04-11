class AddIndexToTagGroup < ActiveRecord::Migration
  def change
    add_index :tag_groups, :course_id
  end
end
