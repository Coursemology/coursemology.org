class Announcement < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :course_id, :creator_id, :description, :important, :publish_at, :title, :expiry_at

  scope :published, lambda { where("publish_at <= ? ", Time.now) }

  belongs_to :course
  belongs_to :creator, class_name: "User"
  has_many :queued_jobs, as: :owner, class_name: "QueuedJob", dependent: :destroy

  #before_destroy :delete_jobs

  def schedule_mail(ucs, redirect_to)
    QueuedJob.destroy(self.queued_jobs)

    unless course.email_notify_enabled? PreferableItem.new_announcement
      return
    end

    delayed_job = Delayed::Job.enqueue(MailingJob.new(course_id, Announcement.to_s, self.id, redirect_to), run_at: self.publish_at)
    self.queued_jobs.create(delayed_job_id: delayed_job.id)
  end

end
