
class MassEnrollmentEmail < ActiveRecord::Base
  attr_accessible :course_id, :name, :email, :signed_up, :delayed_job_id, :confirm_token, :pending_email

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }

  belongs_to :course
  belongs_to :delayed_job, dependent: :destroy

  require 'digest/md5'

  def status
    if signed_up?
      return 'signed up'

    end

    unless delayed_job
      return 'Email sent'
    end

    if delayed_job && delayed_job.failed_at
      'Email failed'
    elsif delayed_job
      return  'Email queued'
    end
  end

  def send_email(lecturer, redirect_url)
    self.delayed_job_id = UserMailer.delay.enrollment_invitation(self.email, self.name, lecturer, self.course.title, redirect_url).id
    self.save
  end

  def generate_confirm_token
    self.confirm_token ||= Digest::MD5.hexdigest(self.email)
    self.save
  end

end
