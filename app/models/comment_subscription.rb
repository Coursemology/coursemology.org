class CommentSubscription < ActiveRecord::Base
  attr_accessible :course_id, :topic_id, :topic_type, :user_course_id

  belongs_to :topic, polymorphic: true
  belongs_to :course
  belongs_to :user_course

  def self.populate_subscription(comment)
    # add the commentator to the subscription list
    commentable = comment.commentable
    commentator = comment.user_course
    CommentSubscription.subscribe(commentable, commentator)
    if commentable.respond_to?(:user_course)
      # add the owner of the topic to the subscription list
      CommentSubscription.subscribe(commentable, commentable.user_course)
    end
    if commentator.is_student?
      # add the ta to the subscription list
      commentator.get_staff_incharge.each do |uc|
        CommentSubscription.subscribe(commentable, uc)
      end
    end
  end

  def self.subscribe(topic, user_course)
    old_cs = CommentSubscription.where(
      user_course_id: user_course.id,
      topic_id: topic.id,
      topic_type: topic.class).count

    if old_cs == 0
      cs = CommentSubscription.new
      cs.topic = topic
      cs.user_course = user_course
      cs.course = user_course.course
      cs.save
      puts cs.to_json
    end
  end
end

