module Commentable

  include ApplicationHelper
  include ActionView::Helpers::DateHelper
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
    if self.pending_comments
      self.pending_comments.update_attribute(:pending, pending)
    else
      self.build_pending_comments(pending:pending).save
    end
  end

  def notify_user(curr_user_course, comment, redirect_url)

    if curr_user_course == self.std_course
      #commented by the student, set pending true
      comment.commentable.set_pending_comments(true)
      self.std_course.get_staff_incharge.each do |uc|
        UserMailer.delay.new_comment(uc.user, comment, redirect_url)
      end
    else
      #commented by the staff, set pending false
      comment.commentable.set_pending_comments(false)
      UserMailer.delay.new_comment(self.std_course.user, comment, redirect_url)
    end
    # TODO add a notification as well
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
