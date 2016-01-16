class BackgroundJob < Struct.new(:course_id, :name, :item_type, :item_id)
  require 'enumerable'

  def perform
    course = Course.find_by_id(course_id)

    begin
      item = item_type.to_s.constantize.find(item_id)
    rescue
      item = nil
    end

    case name
      when :pending_action
        create_pending_actions(course, item)
      when :mission_due
        mission_reminder(course, item)
      when :notification
        new_notification(course, item)
      when :auto_submission
        create_submissions_mission(item)
      when :new_submission
        notify_submission(course, item)
      when :reward_achievement
        check_achievement(course, item)
      when :delete_course
        course.destroy
      when :delete_user
        user = item_type.to_s.constantize.find(item_id)
        user.destroy if user
      else
        raise "background job not supported - #{name}"
    end
  end

  def create_pending_actions(course, item)
    students = course.user_courses.student
    if item.is_a?(Assessment)
      submitted_students = item.submissions.submitted_or_graded.includes(:std_course).map(&:std_course)
      students -= submitted_students
    end

    students.each do |student|
      exists = student.pending_actions.where(item_type: item.class.name, item_id: item.id)
      next if exists.any?

      pending_action = student.pending_actions.build
      pending_action.course = course
      pending_action.item_type = item.class.name
      pending_action.item_id = item.id
      pending_action.save
    end
  end

  def cancel_submissions_mission(asm)
    asm.queued_jobs.where(job_type: :auto_submission).destroy_all
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

  def new_notification(course, item)
    notification_enabled = true
    if item.is_a?(Assessment)
      notification_enabled = course.email_notify_enabled?(PreferableItem.new_assessment(item.as_assessment_type.constantize))
    elsif item.is_a?(Announcement)
      notification_enabled = course.email_notify_enabled?(PreferableItem.new_announcement)
    end
    return unless notification_enabled

    course.user_courses.each do |uc|
      user = uc.user
      case item.class.name.to_sym
        when :Assessment
          UserMailer.delay.new_assessment(user, item, course) if item.published?
        when :Announcement
          UserMailer.delay.new_announcement(user, item, course)
        else
          puts "new notification for #{item}"
      end
    end
  end

  def mission_reminder(course, asm)
    return unless asm && asm.published?
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

  def notify_submission(course, sbm)
    sbm.std_course.get_staff_incharge.each do |uc|
      UserMailer.delay.new_submission(
          uc.user,
          course,
          sbm
      )
    end
  end

  def check_achievement(course, achievement)
    course.user_courses.each do |user_course|
      if user_course.is_student?
        user_course.check_achievement(achievement)
      end
    end
  end
end