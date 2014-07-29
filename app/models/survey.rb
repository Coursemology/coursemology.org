class Survey < ActiveRecord::Base
  acts_as_paranoid
  default_scope { order("open_at") }
  attr_accessible :course_id, :title, :creator_id, :description,
                  :open_at, :expire_at, :anonymous, :publish,
                  :allow_modify, :has_section, :exp


  scope :opened, lambda { where("open_at <= ? ", Time.now) }


  belongs_to :course
  belongs_to :creator, class_name: "User"

  has_many :survey_sections,    dependent: :destroy
  has_many :survey_questions,   dependent: :destroy
  has_many :submissions, class_name: "SurveySubmission", dependent: :destroy
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

  # def dup
  #   clone = super
  #   map = {}
  #   survey_sections.each do |section|
  #     clone_section = section.dup
  #     clone_section.survey = clone
  #     clone_section.save
  #     map[section] = clone_section
  #   end
  #
  #   survey_questions.each do |question|
  #     clone_question = question.dup
  #     clone_question.survey = clone
  #     if question.survey_section
  #       clone_question.survey_section = map[question.survey_section]
  #     end
  #     clone_question.save
  #
  #     question.options.each do |option|
  #       clone_option = option.dup
  #       clone_option.survey_question = clone_question
  #       clone_option.save
  #
  #       if option.file
  #         option.file.dup_owner(clone_option)
  #       end
  #     end
  #   end
  #   clone
  # end

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
