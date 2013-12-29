class Submission < ActiveRecord::Base
  acts_as_paranoid

  include Rails.application.routes.url_helpers
  include Sbm

  attr_accessible :attempt, :status, :final_grading_id, :mission_id, :open_at, :std_course_id, :submit_at, :updated_at

  belongs_to :mission
  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :final_grading, class_name: "SubmissionGrading"

  has_many :std_answers, through: :sbm_answers,
           source: :answer, source_type: "StdAnswer"
  has_many :std_coding_answers, through: :sbm_answers,
           source: :answer, source_type: "StdCodingAnswer"

  has_many :answers, as: :sbm, class_name: "SbmAnswer"

  has_many :files, as: :owner, class_name: "FileUpload", dependent: :destroy

  scope :graded, where(status: 'graded')

  default_scope includes(:mission, :std_course, :final_grading)

  # implement method of Sbm interface
  def get_asm
    self.mission
  end

  def get_path
    course_mission_submission_path(mission.course, mission, self)
  end

  def get_edit_path
    edit_course_mission_submission_path(mission.course, mission, self)
  end

  def get_new_grading_path
    new_course_mission_submission_submission_grading_path(
        mission.course, mission, self)
  end

  def build_initial_answers(current_user)
    self.mission.get_all_questions.each do |qn|
      sa = nil
      if qn.class == Question && !self.std_answers.where(question_id:qn.id).first
        sa = self.std_answers.build({text: ''})
        sa.question = qn
      elsif qn.class == CodingQuestion && !self.std_coding_answers.where(qn_id:qn.id).first
        sa = self.std_coding_answers.build({code: qn.prefilled_code })
        sa.qn = qn
      end
      if sa
        sa.student = current_user
        sa.std_course = self.std_course
        self.save
      end
    end
  end

  def fetch_params_answers(params,current_user)
    answers = params[:answers] ? params[:answers] : []

    answers.each do |type,qn_answers|
      qn_answers.each do |qid, ans|
        if type == CodingQuestion.to_s
          sa = self.std_coding_answers.where(qn_id:qid).first
          if sa
            sa.code = ans
            sa.save
          else
            qn = CodingQuestion.find(qid)
            sa = self.std_coding_answers.build({
                                                   code:ans
                                               })
            sa.qn = qn
            sa.student = current_user
            sa.std_course = self.std_course
          end
        else
          sa = self.std_answers.where(question_id:qid).first
          if sa
            sa.text = ans
            sa.save
          else
            qn = Question.find(qid)
            sa = self.std_answers.build({
                                            text:ans
                                        })
            sa.question = qn
            sa.student = current_user
            sa.std_course = self.std_course
          end
        end
      end
      self.save
    end
    sub_files = params[:files] ? params[:files].values : []
    self.attach_files(sub_files)
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

  def set_attempting
    self.update_attribute(:status,'attempting')
  end

  def set_submitted(redirect_url)
    self.update_attribute(:status,'submitted')
    self.update_attribute(:submit_at, updated_at)
    notify_submission(redirect_url)
  end

  def set_graded
    self.update_attribute(:status,'graded')
  end

  def attempt_mission
    self.set_attempting
    self.attempt = self.attempt ? self.attempt + 1 : 1
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
          mission,
          redirect_url
      )
    end
  end

  def attach_files(files)
    files.each do |id|
      file = FileUpload.find(id)
      file.owner = self
      file.save
    end
  end

end
