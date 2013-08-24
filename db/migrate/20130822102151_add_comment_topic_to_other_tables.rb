class AddCommentTopicToOtherTables < ActiveRecord::Migration
  def change
    add_column :comments, :comment_topic_id, :integer
    add_index :comments, :comment_topic_id

    add_column :comment_subscriptions, :comment_topic_id, :integer
    add_index :comment_subscriptions, :comment_topic_id
  end
end
