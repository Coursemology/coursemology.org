module Commentable

  def get_subscribed_user_courses
    raise NotImplementedError
  end

  def notify_user(curr_user_course, comment, redirect_url)
    # user and all who has commented on this?
    # all lecturers

    # all users?
    #commented by the student
    if curr_user_course == self.std_course
      self.std_course.get_my_tutors.each do |uc|
        UserMailer.delay.new_comment(uc.user, comment, redirect_url)
      end
    else
      UserMailer.delay.new_comment(self.std_course.user, comment, redirect_url)
    end
    # TODO add a notification as well
  end
end
