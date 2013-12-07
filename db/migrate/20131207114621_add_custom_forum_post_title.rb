class AddCustomForumPostTitle < ActiveRecord::Migration
  def change
    add_column :forum_posts, :title, :string, after: :parent_id
  end
end
