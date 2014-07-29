class UserMailer < ActionMailer::Base
  include TruncateHtmlHelper
  helper_method :truncate_html

  default from: "noreply@coursemology.com",
          'Content-Transfer-Encoding' => '7bit'

  def new_comment(user, comment, redirect_url)
    @user = user
    @comment = comment
    @redirect_url = redirect_url
    mail(to: user.email, subject: "New comment by #{@comment.user_course.name}!")
  end

  def new_annotation(user, annotation, assignment, redirect_url)
    @user = user
    @comment = annotation
    @redirect_url = redirect_url
    @assignment = assignment
    mail(to: user.email, subject: "New annotation by #{@comment.user_course.name}!")
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
    mail(to: user.email, subject: "New Submission on : #{mission.title}!")
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

  def new_lecturer_request(user, request)
    @user = user
    @request = request
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
    mail(to: user_email, subject: "#{course_name} New Announcement: #{ann.title}")
  end

  def new_mission(user_name, user_email, mission_title, course, redirect_to)
    @user_name = user_name
    @mission_title = mission_title
    @redirect_to = redirect_to
    mail(to: user_email, subject: "#{course.title}: New #{course.customized_title_by_model(Assessment::Mission).singularize} Available!")
  end

  def new_training(user_name, user_email, training_title, course, redirect_to)
    @user_name = user_name
    @training_title = training_title
    @redirect_to = redirect_to
    mail(to: user_email, subject: "#{course.title}: New #{course.customized_title_by_model(Assessment::Training).singularize} Available!")
  end

  def mission_due(user, mission, course, redirect_to)
    @user_name = user.name
    @mission_title = mission.title
    @due_time = mission.close_at
    @redirect_url = redirect_to
    mail(to: user.email, subject: "#{course.title}: Reminder about #{mission.title}")
  end

  def forum_digest(user, posts, course, date)
    @user = user
    @day = date
    @posts = posts
    @course = course
    @length = 1000

    mail(to: user.user.email, subject: "#{course.title}: Forum digest")
  end

  def forum_new_topic(user, topic, post, course)
    @user = user
    @topic = topic
    @post = post
    @course = course

    mail(to: user.user.email, subject: "#{course.title}: New topic notification")
  end

  def forum_new_post(user, post, course)
    @user = user
    @post = post
    @course = course

    mail(to: user.user.email, subject: "#{course.title}: New post notification")
  end

  def email_changed(user_name, new_email, email_was)
    @user_name = user_name
    @new_email = new_email
    @email_was = email_was
    mail(to: new_email, subject: "Your email has been updated.")
  end

  def enrollment_invitation(std_email, std_name, lecturer, course_title, redirect_url)
    @user_name = std_name
    @lecturer = lecturer
    @course_title = course_title
    @redirect_url = redirect_url
    mail(to: std_email, subject: "Invitation to enroll in: #{course_title}")
  end

  def mission_reminder_summary(students, mission, staff)
    @assignment = mission.title
    @students = students
    @due_date = mission.close_at
    mail(to:staff.email,  subject: "Reminder about #{mission.title}")
  end

  def course_deleted(title, user)
    @user = user
    @title = title
    mail(to: user.email, subject: "Your course has been deleted")
  end

  def user_deleted(name, email)
    @name = name
    mail(to:email, subject: "Your account has been deleted")
  end

  def system_wide_announcement(name, email, subject, body)
    @name = name
    @body = body
    mail(to: email, subject: "[Coursemology] #{subject}")
  end
end
