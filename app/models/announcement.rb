class Announcement < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :course_id, :creator_id, :description, :important, :publish_at, :title, :expiry_at

  scope :published, lambda { where("publish_at <= ? ", Time.now) }

  belongs_to :course
  belongs_to :creator, class_name: "User"
  has_many :queued_jobs, as: :owner, class_name: "QueuedJob", dependent: :destroy
  after_save :schedule_mail, if: :publish_at_changed?

  def schedule_mail
    QueuedJob.destroy(self.queued_jobs)

    return unless course.email_notify_enabled? PreferableItem.new_announcement

    delayed_job = Delayed::Job.enqueue(BackgroundJob.new(course_id, :notification, Announcement.name, self.id), run_at: self.publish_at)
    self.queued_jobs.create(delayed_job_id: delayed_job.id)
  end
end
