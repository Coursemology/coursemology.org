class BackgroundJob < Struct.new(:course_id, :name, :type, :item_id)
  require 'enumerable'
  def perform
    course = Course.find(course_id)

    if name == 'AutoSubmissions'
      if type == 'Create'
        item_id ? create_submissions_mission(Mission.find(item_id)) : create_submissions_course(course)
      elsif type == 'Cancel'
        item_id ? cancel_submissions_mission(Mission.find(item_id)) : cancel_submissions_course(course)
      end
    end

    if name == 'RewardAchievement'
      check_achievement(course, Achievement.find(item_id))
    end

    if name == PendingAction.to_s
      create_pending_actions(course, type, item_id)
    end

  end

  def create_submissions_course(course)
    course.missions.each do |mission|
      if mission.open_at > Time.now
        q = QueuedJob.new
        q.owner = mission
        q.delayed_job_id = Delayed::Job.enqueue(
            BackgroundJob.new(course.id, 'AutoSubmissions', 'Create', mission.id),
            run_at: mission.open_at).id
        q.save
      end
    end
  end

  def create_submissions_mission(mission)
    cancel_submissions_mission(mission)
    mission.course.user_courses.student.each do |uc|
      sbm = Submission.where(std_course_id: uc.id, mission_id: mission.id).first
      unless sbm
        sbm = mission.submissions.build
        sbm.std_course = uc
        sbm.save
      end
      sbm.build_initial_answers(uc.user)
      sbm.update_attribute(:status,'submitted')
      sbm.update_attribute(:submit_at, Time.now)
    end
  end

  def cancel_submissions_course(course)
    course.missions.each do |mission|
      cancel_submissions_mission(mission)
    end
  end

  def cancel_submissions_mission(mission)
    q = QueuedJob.where(owner_id: mission.id, owner_type: mission.class.to_s)
    q.destroy_all
  end

  def check_achievement(course, achievement)
    course.user_courses.each do |user_course|
      if user_course.is_student?
        user_course.check_achievement(achievement)
      end
    end
  end

  def create_pending_actions(course, item_type, item_id)
    course.user_courses.student.each do |std_course|
      exist = std_course.pending_actions.where(item_type: item_type, item_id: item_id).first
      if exist
        next
      end
      pending_act = std_course.pending_actions.build
      pending_act.course = course
      pending_act.item_type = item_type
      pending_act.item_id = item_id
      pending_act.save
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