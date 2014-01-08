class Assessment::Mission < ActiveRecord::Base
  is_a :assessment, as: 'as_assessment_assessment', class_name: 'Assessment::Assessment'

  has_many :dependent, class_name: Assessment::Mission, foreign_key: :id
  has_many :files, as: :owner, class_name: 'FileUpload', dependent: :destroy
  has_many :required_for, class_name: 'Mission', foreign_key: :dependent_id

  attr_accessible :title, :description, :exp, :open_at, :close_at, :publish, :file_submission, :dependent_id

  alias :get_all_questions :questions

  # @deprecated
  def get_final_sbm_by_std(std_course_id)
    submissions.final(std_course_id)
  end

  def open?
    return open_at <= Time.now
  end

  def can_start?(curr_user_course)
    return false if not open?

    if dependent
      submission = Assessment::Submission.where(id: dependent.map { |d| d.assessment }, std_course_id: curr_user_course).first
      return false if !submission || (not submission.submitted?)
    end

    return true
  end

  def attach_files(files)
    files.each do |id|
      file = FileUpload.where(id: id).first
      if file
        file.owner = self
        file.save
      end
    end
  end

  def schedule_mail(ucs, redirect_to)
    QueuedJob.destroy(self.queued_jobs)

    if open_at > Time.now && course.auto_create_sbm_pref.display?
      BackgroundJob.new(course_id, 'AutoSubmissions', 'Cancel', id)
      delayed_job = Delayed::Job.enqueue(BackgroundJob.new(course_id, 'AutoSubmissions', 'Create', id), run_at: open_at)
      queued_jobs.create(delayed_job_id: delayed_job.id)
    end

    if not course.email_notify_enabled?(PreferableItem.new_mission)
      return
    end

    assessment.schedule_mail(ucs, redirect_to)

    if close_at >= Time.now && publish?
      delayed_job = Delayed::Job.enqueue(MailingJob.new(course_id, self.class.to_s, id, redirect_to, true), run_at: 1.day.ago(close_at))
      queued_jobs.create(delayed_job_id: delayed_job.id)
    end
  end

  # Converts this mission into a format that can be used by the lesson plan component
  def as_lesson_plan_entry
    entry = LessonPlanEntry.create_virtual
    entry.title = self.title
    entry.description = self.description
    entry.entry_real_type = "Mission"
    entry.start_at = self.open_at
    entry.end_at = self.close_at
    entry.url = course_mission_path(self.course, self)
    entry.is_published = self.publish
    entry
  end
end
