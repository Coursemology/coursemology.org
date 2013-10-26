class Mission < ActiveRecord::Base

  include Rails.application.routes.url_helpers
  # Assignments may have other assignment as requirement
  # Not implemented yet.
  include HasRequirement
  include ActivityObject
  include Assignment

  attr_accessible :attempt_limit, :auto_graded, :course_id, :close_at, :creator_id, :deadline,
                  :description, :exp, :open_at, :pos, :timelimit, :title, :single_question, :is_file_submission, :dependent_id, :publish

  validates_with DateValidator, fields: [:open_at, :close_at]

  belongs_to :course
  belongs_to :creator, class_name: "User"
  belongs_to :dependent_mission, class_name: "Mission", foreign_key: "dependent_id"

  has_many :questions, through: :asm_qns, source: :qn, source_type: "Question", dependent: :destroy
  has_many :coding_questions, through: :asm_qns, source: :qn, source_type: "CodingQuestion", dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :files, as: :owner, class_name: "FileUpload", dependent: :destroy
  has_many :missions_dependent_on, class_name: "Mission", foreign_key: 'dependent_id'

  def update_grade
    self.max_grade = self.questions.sum(&:max_grade) + self.coding_questions.sum(&:max_grade)
    self.save
  end

  def get_path
    course_mission_path(course, self)
  end

  def get_all_questions
    self.asm_qns.order(:pos).map {|q| q.qn}
  end

  def attach_files(files)
    files.each do |id|
      file = FileUpload.where(id: id).first
      if file
        file.owner = self
        file.save
      end
    end
  end

  def total_exp
    exp
  end

  def can_start?(curr_user_course)
    if open_at > Time.now
      return  false, "Mission hasn't open yet :)"
    end
    if dependent_mission
      sbm = Submission.where(mission_id: dependent_mission, std_course_id: curr_user_course).first
      if !sbm || sbm.attempting?
        return false, "You need to complete #{dependent_mission.title} to unlock this mission :|"
      end
    end
    return true, ""
  end

  # Gets all missions which are within the given date range, as lesson plan entries.
  def as_lesson_plan_entry
    entry = LessonPlanEntry.create_virtual
    entry.title = "Mission: #{self.title}"
    entry.description = self.description
    entry.start_at = self.open_at
    entry.end_at = self.close_at
    entry
  end

  alias_method :sbms, :submissions
end
