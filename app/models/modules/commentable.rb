module Commentable

  def get_subscribed_user_courses
    raise NotImplementedError
  end

  def notify_user(comment, redirect_url)
    # user and all who has commented on this?
    # all lecturers

    # all users?
    to_be_notified = self.get_subscribed_user_courses
    to_be_notified.delete(comment.user_course)
    to_be_notified.each do |uc|
      puts " to email #{uc.user.email}"
      UserMailer.delay.new_comment(uc.user, comment, redirect_url)
      # TODO add a notification as well
    end
  end
end
