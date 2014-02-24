class AddLockedToForumForum < ActiveRecord::Migration
  def change
    add_column :forum_forums, :locked, :boolean, default: false
  end
end
