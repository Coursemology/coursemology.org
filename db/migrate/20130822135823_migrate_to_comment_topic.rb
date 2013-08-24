class MigrateToCommentTopic < ActiveRecord::Migration
  def up
    Comment.all.each do |comment|
      comment_topic = CommentTopic.where(
        topic_id: comment.commentable_id,
        topic_type: comment.commentable_type).first_or_create
      unless comment.user_course
        next
      end
      comment_topic.course = comment.user_course.course
      comment_topic.last_commented_at = comment.created_at
      comment_topic.save

      comment.comment_topic = comment_topic
      comment.save
    end
    CommentSubscription.all.each do |subscription|
      comment_topic = CommentTopic.where(
        topic_id: subscription.topic_id,
        topic_type: subscription.topic_type
      ).first
      if comment_topic
        subscription.comment_topic = comment_topic
        subscription.save
      end
    end
    PendingComments.all.each do |pc|
      comment_topic = CommentTopic.where(
        topic_id: pc.answer_id,
        topic_type: pc.answer_type
      ).first
      if comment_topic
        comment_topic.pending = pc.pending
      end
    end
  end

  def down
  end
end
