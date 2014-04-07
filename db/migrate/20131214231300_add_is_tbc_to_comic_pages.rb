class AddIsTbcToComicPages < ActiveRecord::Migration
  def up
    add_column  :comic_pages, :is_tbc, :boolean, default: false
  end

  def down
    remove_column :comic_pages, :is_tbc
  end
end
