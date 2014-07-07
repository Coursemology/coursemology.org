class Assessment < ActiveRecord::Base
  acts_as_paranoid
  #as is for belong_to association
  acts_as_superclass as: :as_assessment

  default_scope { order("assessments.open_at") }

  attr_accessible   :open_at,:close_at, :exp
  attr_accessible   :title, :description, :tab_id
  attr_accessible   :published

  delegate :dependent_id, :close_at, :bonus_exp, :bonus_cutoff_at, to: :as_assessment

  include HasRequirement
  include ActivityObject

  scope :closed, -> { where("close_at < ?", Time.now) }
  scope :still_open, -> { where("close_at >= ? ", Time.now) }
  scope :opened, -> { where("open_at <= ? ", Time.now) }
  scope :future, -> { where("open_at > ? ", Time.now) }
  scope :published, -> { where(published: true) }
  scope :mission, -> {where(as_assessment_type: "Assessment::Mission")}
  scope :training, -> {where(as_assessment_type: "Assessment::Training")}

  belongs_to  :tab
  belongs_to  :course
  belongs_to  :creator, class_name: "User"

  has_many :as_asm_reqs, class_name: RequirableRequirement, as: :requirable, dependent: :destroy
  has_many :as_requirements, through: :as_asm_reqs

  has_many  :question_assessments
  has_many  :questions, through: :question_assessments do
    def coding
      where(as_question_type: Assessment::CodingQuestion)
    end

    def before(question)
      where(pos: ['< ?', question.pos])
    end
  end

  has_many  :general_questions, class_name: "Assessment::GeneralQuestion", through: :questions,
            source: :as_question, source_type: "Assessment::GeneralQuestion"

  #tags through question tags
  has_many :taggable_tags, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggable_tags

  has_many :queued_jobs, as: :owner, class_name: "QueuedJob", dependent: :destroy
  has_many :pending_actions, as: :item, dependent: :destroy
  has_many :files, as: :owner, class_name: "FileUpload", dependent: :destroy
  has_many :submissions, class_name: "Assessment::Submission",dependent: :destroy, foreign_key: "assessment_id"

  after_save :after_save_asm
  before_update :clean_up_description, :if => :description_changed?

  #was get title
  def title_with_type
    to_translate = self.as_assessment.class == Assessment::Mission ?
        'Assessment.Mission' : 'Assessment.Training'
    "#{I18n.t(to_translate)} : #{self.title}"
  end

  def update_grade
    self.max_grade = self.questions.sum(&:max_grade)
    self.save
  end

  def get_all_questions
    self.questions
  end

  def opened?
    open_at <= Time.now
  end

  def get_path
    raise NotImplementedError
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
    self.asm_qns.each_with_index do |asm_qn, i|
      asm_qn.pos = i
      asm_qn.save
    end
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
  def update_tags(all_tags = [])
    # all_tags = all_tags.collect { |id| id.to_i }
    # removed_asm_tags = []
    # existing_tags = []
    # self.asm_tags.each do |asm_tag|
    #   if !all_tags.include?(asm_tag.tag_id)
    #     removed_asm_tags << asm_tag.id
    #   else
    #     existing_tags << asm_tag.tag_id
    #   end
    # end
    # AsmTag.delete(removed_asm_tags)
    # self.add_tags(all_tags - existing_tags)
  end

  def after_save_asm
    #TODO
    # self.tags.each { |tag| tag.update_max_exp }
  end

  #TODO
  def schedule_tasks(redirect_to)
    # type = self.class
    # QueuedJob.destroy(self.queued_jobs)
    # course = self.course
    #
    # #enqueue pending action job
    # delayed_job = Delayed::Job.enqueue(BackgroundJob.new(course_id, PendingAction.to_s, type.to_s, self.id), run_at: self.open_at)
    # self.queued_jobs.create(delayed_job_id: delayed_job.id)
    #
    # if self.open_at > Time.now && type == Mission && course.auto_create_sbm_pref.display?
    #   BackgroundJob.new(course_id, 'AutoSubmissions', 'Cancel', self.id)
    #   delayed_job = Delayed::Job.enqueue(BackgroundJob.new(course_id, 'AutoSubmissions', 'Create', self.id), run_at: self.open_at)
    #   self.queued_jobs.create(delayed_job_id: delayed_job.id)
    # end
    #
    # if type == Mission && !course.email_notify_enabled?(PreferableItem.new_mission)
    #   return
    # end
    # if type == Training && !course.email_notify_enabled?(PreferableItem.new_training)
    #   return
    # end
    # if self.open_at >= Time.now and self.publish?
    #   delayed_job = Delayed::Job.enqueue(MailingJob.new(course_id, type.to_s, self.id, redirect_to), run_at: self.open_at)
    #   self.queued_jobs.create(delayed_job_id: delayed_job.id)
    # end
    #
    # if type == Mission and self.close_at >= Time.now and self.publish?
    #   delayed_job = Delayed::Job.enqueue(MailingJob.new(course_id, type.to_s, self.id, redirect_to, true), run_at: 1.day.ago(self.close_at))
    #   self.queued_jobs.create(delayed_job_id: delayed_job.id)
    # end
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

end