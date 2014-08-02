class BackgroundJob < Struct.new(:course_id, :name, :item_type, :item_id)
  require 'enumerable'

  def perform
    course = Course.find_by_id(course_id)

    case name
      when :PendingAction
        create_pending_actions(course, item_type, item_id)
      when :AutoSubmissions
        create_submissions_mission(item_type.to_s.constantize.find(item_id))
      when :Notification
        new_notification(item_type, item_id, course)
      when :mission_due
        mission_reminder(item_type, item_id, course)
      else
        puts "else"
    end

    if name == 'RewardAchievement'
      check_achievement(course, Achievement.find(item_id))
    end


    if name == "DeleteCourse"
      course.destroy
    end

    if name == "DeleteUser"
      user = User.find_by_id(item_id)
      user.destroy if user
    end
  end

  def create_pending_actions(course, item_type, item_id)
    course.user_courses.student.each do |sc|
      exist = sc.pending_actions.where(item_type: item_type, item_id: item_id).first
      next if exist
      pa = sc.pending_actions.build
      pa.course = course
      pa.item_type = item_type
      pa.item_id = item_id
      pa.save
    end
  end

  def cancel_submissions_mission(asm)
    asm.queued_jobs.where(job_type: :AutoSubmissions).destroy_all
  end

  def create_submissions_mission(asm)
    cancel_submissions_mission(asm)
    asm.course.user_courses.student.each do |uc|
      sbm = Assessment::Submission.where(std_course_id: uc.id, assessment_id: asm.id).first
      unless sbm
        sbm = asm.submissions.build
        sbm.std_course = uc
        sbm.save
      end
      sbm.build_initial_answers
      sbm.update_attribute(:status,'submitted')
      sbm.update_attribute(:submitted_at, Time.now)
    end
  end

  def new_notification(item_type, item_id, course)
    course.user_courses.each do |uc|
      user = uc.user
      case item_type.to_sym
        when :Assessment
          UserMailer.delay.new_assessment(user, item_type.to_s.constantize.find(item_id), course)
        when :Announcement
        else
          puts "new notification"

      end
    end
  end

  def mission_reminder(item_type, item_id, course)
    asm = item_type.to_s.constantize.find(item_id)
    submitted_std = asm.submissions.map {|sub| sub.std_course.user }
    all_std = course.user_courses.student.where(is_phantom: false).map {|uc| uc.user }

    students = []
    (all_std - submitted_std).each do |user|
      UserMailer.delay.mission_due(user, asm, course)
      students << {name: user.name, email: user.email}
    end

    if students.count > 0
      course.user_courses.staff.each do |staff|
        UserMailer.delay.mission_reminder_summary(students, asm, staff.user)
      end
    end
  end


  def check_achievement(course, achievement)
    course.user_courses.each do |user_course|
      if user_course.is_student?
        user_course.check_achievement(achievement)
      end
    end
  end

  def update_tutor_monitoring(user_course_id)
    ta = UserCourse.find(user_course_id)
    gradings = ta.submission_gradings.includes(:sbm).order(:created_at)
    time_diff = gradings.reduce([]) { |acc, g| (g.created_at - g.sbm.submit_at > 0) ? (acc << g.created_at - g.sbm.submit_at) : acc }
    avg = time_diff.mean
    std_dev = time_diff.standard_deviation
    monitoring = TutorMonitoring.where(user_course_id: user_course_id).first
    if monitoring
      monitoring.average_time = avg
      monitoring.std_dev = std_dev
      monitoring.save
    else
      monitoring = TutorMonitoring.create(course_id. ta.course, user_course_id: user_course_id, average_time: avg, std_dev: std_dev)
      monitoring.save
    end
  end

end