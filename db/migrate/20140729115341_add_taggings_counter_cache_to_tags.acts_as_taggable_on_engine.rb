# This migration comes from acts_as_taggable_on_engine (originally 3)
class AddTaggingsCounterCacheToTags < ActiveRecord::Migration
  class Tag < ActiveRecord::Base

  end

  def self.up
    # add_column :tags, :taggings_count, :integer, default: 0

    Tag.reset_column_information
    Tag.find_each do |tag|
      Tag.reset_counters(tag.id, :taggings)
    end
  end

  def self.down
    remove_column :tags, :taggings_count
  end
end
