class AddIsDigestToCategorySubscription < ActiveRecord::Migration
  def self.up
    add_column :forem_category_subscriptions, :is_digest, :integer, :default => 0

    # Uncomment this line to force caching of existing votes
    # Post.find_each(&:update_cached_votes)
  end

  def self.down
    remove_column :forem_category_subscriptions, :is_digest
  end
end