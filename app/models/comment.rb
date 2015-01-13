class Comment < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :commentable_id, :commentable_type, :comment_topic_id, :text, :user_course_id

  include Commenting

  belongs_to :user_course
  belongs_to :commentable, polymorphic: true
  belongs_to :comment_topic

  after_create :notify_user

  def notify_user
    # notify everyone except the ones who made the comment
    if user_course.course.email_notify_enabled?(PreferableItem.new_comment) and comment_topic.can_access?
      user_courses = comment_topic.user_courses - [user_course]
      user_courses.each do |uc|
        UserMailer.delay.new_comment(uc.user, self, comment_topic.permalink)
      end
    end
  end
end
