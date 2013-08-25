class CommentTopic < ActiveRecord::Base
  default_scope { order("last_commented_at DESC") }

  attr_accessible :course_id, :last_commented_at, :permalink, :topic_id, :topic_type

  belongs_to :topic, polymorphic: true
  belongs_to :course

  has_many :comments
  has_many :comment_subscriptions, dependent: :destroy
  has_many :user_courses, through: :comment_subscriptions

  default_scope includes(:topic)

  def notify_user(curr_user_course, comment, redirect_url)
    # notify everyone except the ones who made the comment
    user_courses = self.user_courses - [curr_user_course]
    user_courses.each do |uc|
      UserMailer.delay.new_comment(uc.user, comment, redirect_url)
    end
  end

  def comments_json(curr_user_course = nil, brief = false)
    responds = []

    self.comments.each do |c|
      edit  = false
      if curr_user_course and (curr_user_course.is_staff? || curr_user_course == c.user_course)
        edit = true
      end
      resp = c.as_json
      resp[:edit] = edit
      responds.append(resp)
    end

    sum = self.comments.count
    brief_resp = []
    if brief and sum > 5
      brief_resp << responds[0]
      brief_resp << { h: sum - 3 }
      brief_resp << responds[sum - 2]
      brief_resp << responds[sum - 1]
      return brief_resp
    end
    responds
  end

  def self.comments_to_json(comment_topic, curr_user_course=nil, brief=false)
    # to handle the case when comment_topic is nil
    comment_topic ? comment_topic.comments_json(curr_user_course, brief) : []
  end
end
