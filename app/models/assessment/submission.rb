class Assessment::Submission < ActiveRecord::Base
  acts_as_paranoid

  include Rails.application.routes.url_helpers
  scope :mission_submissions, -> {
    joins("left join assessments on assessment_submissions.assessment_id = assessments.id ").
        where("assessments.as_assessment_type = 'Assessment::Mission'") }

  scope :training_submissions, -> {
    joins("left join assessments on assessment_submissions.assessment_id = assessments.id ").
        where("assessments.as_assessment_type = 'Assessment::Training'") }

  scope :graded, -> { where(status: 'graded') }

  belongs_to :assessment
  belongs_to :std_course, class_name: "UserCourse"
  has_many :answers, class_name: Assessment::Answer, dependent: :destroy

  has_many :general_answers, class_name: "Assessment::GeneralAnswer",
           through: :answers,
           source: :as_answer, source_type: "Assessment::GeneralAnswer"

  has_many :coding_answers, class_name: "Assessment::CodingAnswer",
           through: :answers,
           source: :as_answer, source_type: "Assessment::CodingAnswer"

  has_many :mcq_answers, class_name: "Assessment::McqAnswer",
           through: :answers,
           source: :as_answer, source_type: "Assessment::McqAnswer"


  has_many :files, as: :owner, class_name: "FileUpload", dependent: :destroy
  has_many :gradings, class_name: Assessment::Grading, dependent: :destroy

  after_create :set_attempting

  def graders
    self.gradings.map(&:grader).select{|g| g}.map(&:name)
  end

  def get_final_grading(build_params = {})
    self.gradings.last || gradings.create(build_params)
  end

  def get_all_answers
    self.answers
  end

  #TODO
  def clear_final_answer(qn)
    self.answers.final.each do |sbm_ans|
      if sbm_ans.qn == qn
        sbm_ans.final = false
        sbm_ans.save
        break
      end
    end
  end

  def has_multiplier?
    self.respond_to?(:multiplier) && self.multiplier
  end

  def get_bonus
    specific = assessment.specific
    if specific.respond_to? :bonus_cutoff
      if specific.bonus_cutoff && specific.bonus_cutoff > Time.now
        return specific.bonus_exp
      end
    end
    0
  end

  def set_attempting
    self.update_attribute(:status,'attempting')
  end

  #TODO
  def set_submitted(redirect_url = "", notify = true)
    self.update_attribute(:status,'submitted')
    self.update_attribute(:submitted_at, updated_at)

    pending_action = std_course.pending_actions.where(item_type: Assessment.to_s, item_id: self.assessment.id).first
    pending_action.set_done if pending_action

    notify_submission(redirect_url) if notify
  end

  def notify_submission(redirect_url)
    unless std_course.course.email_notify_enabled?(PreferableItem.new_submission)
      return
    end
    std_course.get_staff_incharge.each do |uc|
      #TODO: logging
      UserMailer.delay.new_submission(
          uc.user,
          std_course.user,
          assessment,
          redirect_url
      )
    end
  end

  def set_graded
    self.update_attribute(:status,'graded')
  end

  def attempting?
    self.status == 'attempting'
  end

  def submitted?
    self.status == 'submitted'
  end

  def graded?
    self.status == 'graded'
  end

  def get_path
    course_assessment_submission_path(std_course.course, assessment, self)
  end

  def get_new_grading_path
    '#'
  end

  def done?
    self.assessment.questions.finalised(self).count == self.assessment.questions.count
  end

  def update_grade
    self.submitted_at = DateTime.now
    self.set_graded

    pending_action = std_course.pending_actions.where(item_type: self.assessment.class.to_s, item_id: self.id).first
    pending_action.set_done if pending_action

    grading = self.get_final_grading
    grading.update_grade
    grading.save
    grading.exp
  end

  def build_initial_answers
    self.assessment.questions.includes(:as_question).each do |qn|
      unless self.answers.find_by_question_id(qn.id)
        case
          when qn.is_a?(Assessment::GeneralQuestion)
            ans_class = Assessment::GeneralAnswer
          when qn.is_a?(Assessment::CodingQuestion)
            ans_class = Assessment::CodingAnswer
          when qn.is_a?(Assessment::McqQuestion)
            ans_class = Assessment::McqQuestion
          else
            ans_class = Assessment::GeneralAnswer
        end

        ans_class.create!({std_course_id: std_course_id,
                           question_id: qn.id,
                           #TODO, a acts_as_relation bug, parent can access children attributes, but respond_to return false
                           content: qn.specific.respond_to?(:template) ? qn.template : nil,
                           submission_id: self.id,
                           attempt_left: qn.attempt_limit})
      end
    end
  end

  def fetch_params_answers(params)
    answers =  params[:answers] || []

    answers.each do |qid, ans|
      sa = self.answers.find_by_question_id(qid)
      sa.content = ans
      sa.save
    end

    sub_files = params[:files] ? params[:files].values : []
    self.attach_files(sub_files)
  end

  def attach_files(files)
    files.each do |id|
      file = FileUpload.find(id)
      file.owner = self
      file.save
    end
  end

  #TODO
  # def assignment
  #   training
  # end
end