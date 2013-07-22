class Submission < ActiveRecord::Base
  acts_as_paranoid

  include Rails.application.routes.url_helpers
  include Sbm

  attr_accessible :attempt, :final_grading_id, :mission_id, :open_at, :std_course_id, :submit_at

  belongs_to :mission
  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :final_grading, class_name: "SubmissionGrading"

  has_many :std_answers, through: :sbm_answers,
           source: :answer, source_type: "StdAnswer"
  has_many :files, as: :owner, class_name: "FileUpload", dependent: :destroy

  scope :graded, lambda { where("final_grading_id IS NOT NULL") }

  # implement method of Sbm interface
  def get_asm
    self.mission
  end

  def get_path
    course_mission_submission_path(mission.course, mission, self)
  end

  def get_new_grading_path
    new_course_mission_submission_submission_grading_path(
        mission.course, mission, self)
  end

  def build_std_answers(params,current_user)
    answers = params[:answers] ? params[:answers] : []
    answers.each do |qid, ans|
      @wq = Question.find(qid)
      sa = self.std_answers.build({
                                             text: ans,
                                         })
      sa.question = @wq
      sa.student = current_user
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
end
