class AddIndexToCommentSubscription < ActiveRecord::Migration
  def change
    add_index :comment_subscriptions, :course_id
    add_index :comment_subscriptions, [:topic_id, :topic_type]
    add_index :comment_subscriptions, :user_course_id
  end
end
