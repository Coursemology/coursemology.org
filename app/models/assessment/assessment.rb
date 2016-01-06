class Assessment < ActiveRecord::Base
  acts_as_paranoid
  acts_as_duplicable
  #as is for belong_to association
  acts_as_superclass as: :as_assessment

  delegate :full_title, to: :as_assessment

  include Rails.application.routes.url_helpers

  default_scope { order("assessments.open_at") }

  attr_accessible :exp, :bonus_exp
  attr_accessible :title, :description
  attr_accessible :published, :comment_per_qn
  attr_accessible :open_at, :close_at, :bonus_cutoff_at
  attr_accessible :tab_id, :display_mode_id, :dependent_on_attributes
  attr_accessible :dependent_on, :dependent_on_ids, :dependent_id

  validates_presence_of :title


  include HasRequirement
  include ActivityObject

  scope :closed, -> { where("close_at < ?", Time.now) }
  scope :still_open, -> { where("close_at >= ? ", Time.now) }
  scope :opened, -> { where("open_at <= ? ", Time.now) }
  scope :future, -> { where("open_at > ? ", Time.now) }
  scope :published, -> { where(published: true) }
  scope :mission, -> { where(as_assessment_type: "Assessment::Mission") }
  scope :training, -> { where(as_assessment_type: "Assessment::Training") }

  belongs_to  :tab
  belongs_to  :course
  belongs_to  :creator, class_name: "User"
  belongs_to  :display_mode, class_name: "AssignmentDisplayMode", foreign_key: "display_mode_id"

  has_and_belongs_to_many :dependent_on,
                          class_name: "Assessment",
                          foreign_key: :id,
                          association_foreign_key: :dependent_id,
                          join_table: :assessment_dependency

  has_and_belongs_to_many :required_for,
                          class_name: "Assessment",
                          foreign_key: :dependent_id,
                          association_foreign_key: :id,
                          join_table: :assessment_dependency

  accepts_nested_attributes_for :dependent_on, allow_destroy: true

  has_many  :as_asm_reqs, class_name: "AsmReq", as: :asm, dependent: :destroy
  has_many  :as_requirements, through: :as_asm_reqs, source: :as_requirements

  has_many  :question_assessments
  has_many  :questions, through: :question_assessments do
    def coding
      where(as_question_type: Assessment::CodingQuestion)
    end

    def mcq
      where(as_question_type: Assessment::McqQuestion)
    end

    #TODO
    def before(question, pos = 0)
      if question.persisted?
        before_pos(proxy_association.owner.question_assessments.where(question_id: question.id).first.position)
      else
        before_pos(pos)
      end
    end

    def before_pos(position)
      where('position < ?', position)
    end
  end

  has_many :tags, through: :questions

  has_many  :general_questions, class_name: "Assessment::GeneralQuestion",
            through: :questions,
            source: :as_question, source_type: "Assessment::GeneralQuestion"

  has_many  :mcqs, class_name: "Assessment::Question",
            through: :question_assessments,
            source: :question,
            conditions: {as_question_type: "Assessment::McqQuestion"}
  has_many  :files, as: :owner, class_name: "FileUpload", dependent: :destroy

  has_many  :queued_jobs, as: :owner, class_name: "QueuedJob", dependent: :destroy
  has_many  :pending_actions, as: :item, dependent: :destroy
  has_many  :submissions, class_name: "Assessment::Submission",dependent: :destroy, foreign_key: "assessment_id"

  amoeba do
    clone [:questions]
    include_field [:questions, :as_asm_reqs, :dependent_on]
    # as_requirements
  end

  #callbacks
  before_update :clean_up_description, :if => :description_changed?
  after_save :update_opening_tasks, if: [:open_at_changed?, :published]
  after_save :update_closing_tasks, if: [:close_at_changed?, :published]
  after_save :create_or_destroy_tasks, if: :published_changed?



  def self.submissions
    Assessment::Submission.where(assessment_id: self.all)
  end

  def get_title
    full_title
  end

  def update_grade
    self.update_attribute(:max_grade, self.questions.sum(&:max_grade))
  end

  def get_all_questions
    self.questions
  end

  def opened?
    open_at <= Time.now
  end

  def is_mission?
    as_assessment_type == Assessment::Mission.name
  end

  def is_training?
    as_assessment_type == Assessment::Training.name
  end

  def single_question?
    questions.count == 1
  end

  def last_submission(user_course_id)
    self.submissions.where(std_course_id: user_course_id).order(created_at: :desc).first
  end

  def get_final_sbm_by_std(std_course_id)
    self.submissions.find_by_std_course_id(std_course_id)
  end

  def get_qn_pos(qn)
    self.asm_qns.each_with_index do |asm_qn, i|
      if asm_qn.qn == qn
        return (asm_qn.pos || i) + 1
      end
    end
    -1
  end

  def update_qns_pos
    question_assessments.each_with_index do |qa, i|
      qa.position = i
      qa.save
    end
  end

  def get_path
    is_mission? ?
        course_assessment_mission_path(self.course, self.specific) :
        course_assessment_training_path(self.course, self.specific)
  end

  def as_lesson_plan_entry
    entry = LessonPlanEntry.create_virtual
    entry.title = self.title
    entry.description = self.description
    entry.entry_real_type = course.customized_title(is_mission? ? "Mission" : "Training")
    entry.start_at = self.open_at
    entry.end_at = self.close_at  if self.respond_to? :close_at
    entry.url = get_path
    entry.is_published = self.published
    entry
  end

  def add_tags(tags)
    tags ||= []
    tags.each do |tag_id|
      self.asm_tags.build(
          tag_id: tag_id,
          max_exp: exp
      )
    end
    self.save
  end

  #TODO
  def can_start?(curr_user_course)
    return true if submissions.where(std_course_id: curr_user_course.id).any?

    if opened? || course.ignore_assessment_start_at?
      get_dependent_assessment(curr_user_course).empty?
    else
      false
    end
  end

  def get_dependent_assessment(curr_user_course) # returns nil if no pending assessments
    unless dependent_on.count #if no dependencies
      return nil
    end
    unfinished_assessment = []
    dependent_on.each do |asm|
      sbm = asm.submissions.where(std_course_id: curr_user_course).first
      unfinished_assessment << asm if !sbm || sbm.attempting?
    end
    unfinished_assessment
  end

  #TOFIX: it's better to have callback rather than currently directly call this in
  #create. Can't use after_create because files association won't be updated upon save
  def create_local_file
    files.each do |file|
      PythonEvaluator.create_local_file_for_asm(self, file)
    end
  end

  #clean up messed html tags
  def clean_up_description
    self.description = CoursemologyFormatter.clean_code_block(description)
  end

  def dup_options(dup_files = true)
    clone = dup
    clone.save
    if dup_files
      files.each do |file|
        file.dup_owner(clone)
      end
      folder_path = PythonEvaluator.get_asm_file_path(self)
      if File.exist? folder_path
        copy_path = PythonEvaluator.get_asm_file_path(clone)
        FileUtils.mkdir_p(copy_path) unless File.exist?(copy_path)
        FileUtils.cp_r(folder_path + "." , copy_path)
      end
    end
    clone
  end

  def mark_refresh_autograding
    Thread.new {
      submissions.each do |s|
        s.gradings.each do |sg|
          sg.update_attribute(:autograding_refresh, true)
        end
      end
    }
  end

  def current_exp
    exp
  end

  def total_exp
    bonus_exp ? bonus_exp + exp : exp 
  end

  def dup
    s = self.specific
    d = s.dup
    asm = super
    d.assessment = asm
    asm.as_assessment = d
    asm
  end

  def attach_files(files)
    files.each do |id|
      file = FileUpload.find id
      if file
        file.owner = self
        file.save
      end
    end
  end

  #callbacks
  def update_opening_tasks
    #1. pending actions
    #2. auto submission
    #3. email notifications
    tks = {pending_action: true,
           auto_submission:  is_mission? && course.auto_create_sbm_pref.enabled?,
           notification: self.open_at >= Time.now &&
               course.email_notify_enabled?(PreferableItem.new_assessment(as_assessment_type.constantize)) }

    tks.each do |type, condition|
      next unless condition
      create_delayed_job(type, self.open_at)
    end
  end

  def update_closing_tasks
    #1. remainder
    type = :mission_due
    if is_mission? and self.close_at >= Time.now and course.email_notify_enabled?(type.to_s)
      create_delayed_job(type, 1.day.ago(self.close_at))
    end
  end

  def create_delayed_job(type, run_at)
    self.queued_jobs.where(job_type: type).destroy_all
    delayed_job = Delayed::Job.enqueue(BackgroundJob.new(course, type, Assessment.to_s.to_sym, self.id),
                                       run_at: run_at)
    self.queued_jobs.create({delayed_job_id: delayed_job.id, job_type: type})
  end

  def create_or_destroy_tasks
    if published?
      update_opening_tasks
      update_closing_tasks
    else
      self.queued_jobs.destroy_all
    end
  end
end
