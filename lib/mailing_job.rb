class MailingJob < Struct.new(:course_id, :type, :type_id, :redirect_to)
  def perform
    course = Course.find_by_id(course_id)
    case type
      when Announcement.to_s
        new_announcements(Announcement.find(type_id), course)
      when Mission.to_s
        new_mission(Mission.find(type_id), course)
      when Training.to_s
        new_training(Training.find(type_id), course)
      when MassEnrollmentEmail.to_s
        enrollment_invitations(MassEnrollmentEmail.find_all_by_course_id(course_id), course)
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
      delayed_job = UserMailer.delay.enrollment_invitation(enrol.email, enrol.name, lecturer.name, course.title, redirect_to)
      enrol.delayed_job_id = delayed_job.id
      enrol.save
    end
  end
end