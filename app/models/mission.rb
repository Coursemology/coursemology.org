class Mission < ActiveRecord::Base

  include Rails.application.routes.url_helpers
  # Assignments may have other assignment as requirement
  # Not implemented yet.
  include HasRequirement
  include ActivityObject
  include AssignmentModule

  default_scope { order("missions.open_at") }

  attr_accessible :attempt_limit, :auto_graded, :course_id, :close_at, :creator_id, :deadline,
                  :description, :exp, :open_at, :pos, :timelimit, :title, :single_question,
                  :is_file_submission, :dependent_id, :publish,
                  :file_submission_only, :display_mode, :comment_per_qn

  validates_with DateValidator, fields: [:open_at, :close_at]

  belongs_to :course
  belongs_to :creator, class_name: "User"
  belongs_to :dependent_mission, class_name: "Mission", foreign_key: "dependent_id"
  belongs_to :assignment_display_mode, class_name: "AssignmentDisplayMode", foreign_key: "display_mode"

  has_many :questions, through: :asm_qns, source: :qn, source_type: "Question", dependent: :destroy
  has_many :coding_questions, through: :asm_qns, source: :qn, source_type: "CodingQuestion", dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :missions_dependent_on, class_name: "Mission", foreign_key: 'dependent_id'

  def update_grade
    self.max_grade = self.questions.sum(&:max_grade) + self.coding_questions.sum(&:max_grade)
    self.save
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

  # Converts this mission into a format that can be used by the lesson plan component
  def as_lesson_plan_entry
    entry = LessonPlanEntry.create_virtual
    entry.title = self.title
    entry.description = self.description
    entry.entry_real_type = "Mission"
    entry.start_at = self.open_at
    entry.end_at = self.close_at
    entry.url = course_mission_path(self.course, self)
    entry.is_published = self.publish
    entry
  end

  def published?
    publish?
  end

  def get_path
    course_mission_path(self.course, self)
  end

  def missions_dep_on_published
    missions_dependent_on.where(publish:true)
  end

  def current_exp
    exp
  end

  def mark_refresh_autograding
    Thread.new {
      submissions.each do |s|
        s.submission_gradings.each do |sg|
          sg.update_attribute(:autograding_refresh, true)
        end
      end
    }
  end

  alias_method :sbms, :submissions
end
