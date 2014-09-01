class Survey < ActiveRecord::Base
  acts_as_paranoid
  acts_as_duplicable
  default_scope { order("open_at") }
  attr_accessible :course_id, :title, :creator_id, :description,
                  :open_at, :expire_at, :anonymous, :publish,
                  :allow_modify, :has_section, :exp


  scope :opened, lambda { where("open_at <= ? ", Time.now) }


  belongs_to :course
  belongs_to :creator, class_name: "User"

  has_many :survey_sections,    dependent: :destroy
  has_many :survey_questions, through: :survey_sections, dependent: :destroy
  has_many :survey_submissions, class_name: "SurveySubmission", dependent: :destroy
  has_many :pending_actions, as: :item, dependent: :destroy
  has_many :queued_jobs, as: :owner, class_name: "QueuedJob", dependent: :destroy

  amoeba do
    include_field :survey_sections
  end

  after_create :update_pending_actions
  after_update :update_pending_actions

  def update_pending_actions
    QueuedJob.destroy(self.queued_jobs)

    #enqueue pending action job
    delayed_job = Delayed::Job.enqueue(BackgroundJob.new(course_id, PendingAction.to_s, Survey.to_s, self.id), run_at: self.open_at)
    self.queued_jobs.create(delayed_job_id: delayed_job.id)
  end

  def submissions
    survey_submissions
  end

  def questions
    survey_questions
  end

  def can_start?
    open_at <= Time.now
  end

  def submission_by(user_course)
    self.submissions.where(user_course_id: user_course).first
  end

  def sections
    survey_sections
  end

  def close_at
    expire_at
  end

  def current_exp
    exp
  end

  def published?
    publish
  end
end
