module Commentable

  include ApplicationHelper
  include ActionView::Helpers::DateHelper
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

  def comments_json
    responds = []
    self.comments.each do |c|
      responds.append({
                          c:  style_format(c.text),
                          s:  -1,
                          e:  -1,
                          id: c.id,
                          t:  time_ago_in_words(c.updated_at),
                          u:  '<span class="student-link"><a href="'+c.user_course.get_path+'">'+c.user_course.user.name+'</a></span>',
                          p:  c.user_course.user.get_profile_photo_url
                      })
    end
    responds
  end

end
