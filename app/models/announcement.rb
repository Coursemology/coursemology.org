class Announcement < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :course_id, :creator_id, :description, :important, :publish_at, :title

  scope :published, lambda { where("publish_at <= ? ", Time.now) }

  belongs_to :course
  belongs_to :creator, class_name: "User"
  has_many :queued_jobs, as: :owner, class_name: "QueuedJob", dependent: :destroy

  #before_destroy :delete_jobs

  def notify(ucs, redirect_to)
    QueuedJob.destroy(self.queued_jobs)
    ucs.each do |uc|
      user = uc.user

      delayed_job = UserMailer.delay(:run_at => self.publish_at).new_announcement(user.name, self.description, user.email, redirect_to, self.course.title)
      self.queued_jobs.create(delayed_job_id: delayed_job.id)
    end
  end

end
