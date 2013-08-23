class BackgroundJob < Struct.new(:course_id, :name, :type, :item_id)
  def perform
    course = Course.find(course_id)

    if name == 'AutoSubmissions'
      if type == 'Create'
        item_id ? create_submissions_mission(Mission.find(item_id)) : create_submissions_course(course)
      elsif type == 'Cancel'
        item_id ? cancel_submissions_mission(Mission.find(item_id)) : cancel_submissions_course(course)
      end
    end
  end

  def create_submissions_course(course)
    course.missions.each do |mission|
      if mission.open_at > Time.now
        q = QueuedJob.new
        q.owner = mission
        q.delayed_job_id = Delayed::Job.enqueue(BackgroundJob.new(course.id, 'AutoSubmissions', 'Create', mission.id), run_at: mission.open_at).id
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
end