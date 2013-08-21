module Commentable
  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  def self.included(base)
    base.class_eval do
      has_many :comment_subscriptions, as: :topic, dependent: :destroy
      has_many :user_courses, through: :comment_subscriptions
    end
  end

  def pending?
    if self.pending_comments
      self.pending_comments.pending?
    else
      false
    end
  end

  def set_pending_comments(pending)
    if self.respond_to?(:pending_comments)
      # TODO support pending comments for mcq & coding question
      if self.pending_comments
        self.pending_comments.update_attribute(:pending, pending)
      else
        pc = self.create_pending_comments(pending:pending)
        pc.course = std_course.course
        pc.save
      end
    end
  end

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
      puts curr_user_course.to_json
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
end
