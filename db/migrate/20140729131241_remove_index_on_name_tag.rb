class RemoveIndexOnNameTag < ActiveRecord::Migration
  def up
    remove_index :tags, :name
    add_index :tags, :name, unique: false
  end

  def down
  end
end
