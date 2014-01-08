class Assessment::Assessment < ActiveRecord::Base
  acts_as_superclass as: :as_assessment_assessment

  has_and_belongs_to_many :tags, class_name: Tag, join_table: :assessment_assessments_tags
  has_many :assessment_requirements, class_name: Assessment::AssessmentsRequirement, dependent: :destroy
  has_many :requirements, class_name: Requirement, through: :assessment_requirements
  has_many :queued_jobs, as: :owner, class_name: QueuedJob, dependent: :destroy
  belongs_to :course, class_name: 'Course'
  belongs_to :creator, class_name: 'User'

  has_many :questions, class_name: Assessment::Question, order: 'pos ASC' do
    def coding
      where(as_assessment_question_type: Assessment::CodingQuestion)
    end

    def before(question)
      where(pos: ['< ?', question.pos])
    end
  end
  has_many :submissions, class_name: Assessment::Submission do
    def final(student_course)
      last = where(std_course_id: student_course).last
      last = last.specific if last
      # self.sbms.find_by_std_course_id(std_course_id)
    end
  end

  alias :as_requirements :requirements

  # @deprecated
  def is_file_submission
    file_submission?
  end

  # @deprecated
  def single_question
    questions.count <= 1
  end
  alias_method :single_question?, :single_question

  def max_grade
    questions.sum(:max_grade)
  end

  def schedule_mail(ucs, redirect_to)
    type = specific.class
    if type == Assessment::Training && !course.email_notify_enabled?(PreferableItem.new_training)
      return
    end

    # Queue the open email
    if open_at >= Time.now and publish?
      delayed_job = Delayed::Job.enqueue(MailingJob.new(course_id, type.to_s, id, redirect_to), run_at: open_at)
      queued_jobs.create(delayed_job_id: delayed_job.id)
    end
  end

  def update_tags(all_tags)
    all_tags ||= []
    all_tags = all_tags.collect { |id| id.to_i }
    existing_tags = []
    tags.each do |asm_tag|
      if !all_tags.include?(asm_tag.id)
        tags.delete(asm_tag)
      else
        existing_tags << asm_tag.tag_id
      end
    end

    add_tags(all_tags - existing_tags)
  end

private
  def add_tags(tags)
    tags ||= []
    tags.each do |tag_id|
      self.tags << Tag.find_by_id!(tag_id)
    end
  end
end
