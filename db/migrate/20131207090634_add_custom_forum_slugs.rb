class AddCustomForumSlugs < ActiveRecord::Migration
  def change
    rename_column :forum_forums, :slug, :cached_slug

    add_column :forum_topics, :title, :string, after: :forum_id
    rename_column :forum_topics, :slug, :cached_slug
  end
end
