class CommentSubscription < ActiveRecord::Base
  attr_accessible :course_id, :comment_topic_id, :topic_id, :topic_type, :user_course_id

  belongs_to :comment_topic
  belongs_to :course
  belongs_to :user_course

  def self.populate_subscription(comment)
    # add the commentator to the subscription list
    # commentable = comment.commentable
    comment_topic = comment.comment_topic
    commentator = comment.user_course

    if !comment_topic|| !commentator
      return
    end

    CommentSubscription.subscribe(comment_topic, commentator)
    if comment_topic.topic && comment_topic.topic.respond_to?(:user_course)
      # add the owner of the topic to the subscription list
      CommentSubscription.subscribe(comment_topic, comment_topic.topic.user_course)
    end
    if commentator.is_student?
      # add the ta to the subscription list
      commentator.get_my_tutors.each do |uc|
        CommentSubscription.subscribe(comment_topic, uc)
      end
    end
  end

  def self.subscribe(comment_topic, user_course)
    old_cs = CommentSubscription.where(
      user_course_id: user_course.id,
      comment_topic_id: comment_topic.id).count

    if old_cs == 0
      cs = CommentSubscription.new
      cs.comment_topic = comment_topic
      cs.user_course = user_course
      cs.course = user_course.course
      cs.save
      puts cs.to_json
    end
  end

  def self.unsubscribe(comment_topic, user_course)
    cs = CommentSubscription.where(
        user_course_id: user_course.id,
        comment_topic_id: comment_topic.id)
    if cs
      cs.destroy_all
    end
  end
end

