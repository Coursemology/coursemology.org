class DropOldTags < ActiveRecord::Migration
  def up
    drop_table :old_tags
  end

  def down
  end
end
