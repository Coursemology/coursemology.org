class AddNotifiedToTopics < ActiveRecord::Migration
  def self.up
    add_column :forem_topics, :notified, :integer, :default => 0

    # Uncomment this line to force caching of existing votes
    # Post.find_each(&:update_cached_votes)
  end

  def self.down
    remove_column :forem_topics, :notified
  end
end