class AddTagGroupIdToTag < ActiveRecord::Migration
  def change
    add_column :tags, :tag_group_id, :integer
  end
end
