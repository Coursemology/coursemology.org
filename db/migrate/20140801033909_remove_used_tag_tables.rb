class RemoveUsedTagTables < ActiveRecord::Migration
  def up
    drop_table :std_tags
    drop_table :taggings
  end

  def down
  end
end
