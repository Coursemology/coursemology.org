class RemoveUsedForumPostVotes < ActiveRecord::Migration
  def up
    drop_table :forum_post_votes
  end

  def down
  end
end
