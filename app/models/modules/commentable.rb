module Commentable
  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  def self.included(base)
    base.class_eval do
      has_many :comment_subscriptions, as: :topic, dependent: :destroy
      has_many :user_courses, through: :comment_subscriptions
    end
  end

  def get_subscribed_user_courses
    raise NotImplementedError
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
        self.build_pending_comments(pending:pending).save
      end
    end
  end

  def notify_user(curr_user_course, comment, redirect_url)
    # notify everyone except the ones who made the comment
    user_courses = self.user_courses - [curr_user_course]
    puts '----------------'
    user_courses.each do |uc|
      puts 'Notify ', uc.to_json
      UserMailer.delay.new_comment(uc.user, comment, redirect_url)
    end
    puts '----------------'
  end

  def comments_json
    responds = []

    self.comments.each do |c|
      responds.append({
                          c:  style_format(c.text),
                          s:  -1,
                          e:  -1,
                          id: c.id,
                          t:  datetime_no_seconds(c.updated_at),
                          u:  '<span class="student-link"><a href="'+c.user_course.get_path+'">'+c.user_course.user.name+'</a></span>',
                          p:  c.user_course.user.get_profile_photo_url
                      })
    end
    responds
  end
end
