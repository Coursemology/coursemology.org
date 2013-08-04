class UserMailer < ActionMailer::Base
  default from: "coursemology@gmail.com"

  def new_comment(user, comment, redirect_url)
    puts "to email #{user.email} comment #{comment.text}"
    puts "redirect #{redirect_url}"
    @user = user
    @comment = comment
    @redirect_url = redirect_url
    mail(to: user.email, subject: "New comment by #{@comment.user_course.user.name}!")
  end

  def new_grading(user, redirect_url)
    puts "to email #{user.email} redirect #{redirect_url}"
    @user = user
    @redirect_url = redirect_url
    mail(to: user.email, subject: "New Grading available!")
  end

  def new_submission(user, submitted_by, mission, redirect_url)
    puts "to email #{user.email} redirect #{redirect_url}"
    @user = user
    @redirect_url = redirect_url
    @submitted_by = submitted_by
    mail(to: user.email, subject: "New Submission on Mission: #{mission.title}!")
  end

  def new_lecturer(user)
    @user = user
    mail(to: user.email, subject: "You are now a lecturer on Coursemology!")
  end

  def new_student(user, course)
    @user = user
    @course = course
    mail(to: user.email, subject: "You are enrolled in to the course #{course.title}!")
  end

  def new_lecturer_request(user)
    @user = user
    mail(to: user.email, subject: "New lecturer request!")
  end

  def update_user_role(user)
    @user = user
    mail(to:user.email, subject: "You are now #{user.get_role} on Coursemology!")
  end

  def new_enroll_request(enroll_request, lecturer,redirect_url)
    @course =  enroll_request.course
    @role = enroll_request.role
    @user = enroll_request.user
    @lecturer = lecturer
    @redirect_url = redirect_url
    mail(to:lecturer.email, subject: "New enroll request for your course on Coursemology")
  end

  def new_announcement(user_name, ann, user_email, redirect_to, course_name)
    @user_name = user_name
    @redirect_url = redirect_to
    @ann = ann
    @course_name = course_name
    mail(to: user_email, subject: "#{course_name}: New Announcement")
  end

end
