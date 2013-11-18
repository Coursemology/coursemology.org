class MailingJob < Struct.new(:course_id, :type, :type_id, :redirect_to, :reminder)
  def perform
    course = Course.find_by_id(course_id)
    if reminder
      mission_reminder(Mission.find(type_id), course)
      return
    end
    case type
      when Announcement.to_s
        new_announcements(Announcement.find(type_id), course)
      when Mission.to_s
        new_mission(Mission.find(type_id), course)
      when Training.to_s
        new_training(Training.find(type_id), course)
      when MassEnrollmentEmail.to_s
        enrollment_invitations(MassEnrollmentEmail.where(course_id: course_id, signed_up: false), course)
      when Forem::SubscriptionMailer.to_s
        # daily forum new posts digest email
        forum_digest(course)
    end
  end

  def new_announcements(ann, course)
    course.user_courses.each do |uc|
      user = uc.user
      UserMailer.delay.new_announcement(user.name, ann, user.email, redirect_to, course.title)
    end
  end

  def new_mission(mission, course)
    course.user_courses.each do |uc|
      user = uc.user
      UserMailer.delay.new_mission(user.name , user.email, mission.title, course.title, redirect_to)
    end
  end

  def new_training(training, course)
    course.user_courses.each do |uc|
      user = uc.user
      UserMailer.delay.new_training(user.name , user.email, training.title, course.title, redirect_to)
    end
  end

  def enrollment_invitations(enrols, course)
    lecturer = User.find(type_id)
    enrols.each do |enrol|
      enrol.generate_confirm_token
      url = redirect_to + "?_token="+ enrol.confirm_token
      delayed_job = UserMailer.delay.enrollment_invitation(enrol.email, enrol.name, lecturer.name, course.title, url)
      enrol.delayed_job_id = delayed_job.id
      enrol.save
    end
  end

  def mission_reminder(mission, course)
    submitted_std = mission.submissions.map {|sub| sub.std_course.user }
    all_std = course.user_courses.student(is_phantom: false).map {|uc| uc.user }

    students = []
    (all_std - submitted_std).each do |user|
      UserMailer.delay.mission_due(user, mission, course, redirect_to)
      students << {name: user.name, email: user.email}
    end

    if students.count > 0
      course.user_courses.staff.each do |staff|
        UserMailer.delay.mission_reminder_summary(students, mission, staff.user)
      end
    end
  end

  def forum_digest(course)
    subscriptions = Forem::CategorySubscription.where(category_id: course.id, is_digest: true)

    yesterday = (Time.now.midnight - 1.day)..(Time.now.end_of_day - 1.day)

    posts = Forem::Post.includes(:user).includes(topic: :forum).where(created_at: yesterday)
            .where('forem_forums.category_id = ?', course.id).order(topic_id: :asc, created_at: :asc)

    # only deliver when there is at least 1 mail
    if posts.size > 0
      subscriptions.each do |sub|
        Forem::SubscriptionMailer.delay.digest(posts, sub.subscriber, course, yesterday)
      end
    end


  end

end