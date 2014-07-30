class RenameTagsToOldTags < ActiveRecord::Migration
  def up
    rename_table :tags, :old_tags
  end

  def down
  end
end
