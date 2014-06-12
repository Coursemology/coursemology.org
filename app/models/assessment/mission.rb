class Assessment::Mission < ActiveRecord::Base
  acts_as_paranoid
  is_a :assessment, as: :as_assessment, class_name: "Assessment"

  attr_accessible :close_at

  validates_with DateValidator, fields: [:open_at, :close_at]

  belongs_to  :dependent_on, class_name: "Assessment::Mission", foreign_key: "dependent_id"
  has_many    :dependent_by, class_name: Assessment::Mission, foreign_key: 'dependent_id'
  belongs_to  :display_mode, class_name: "AssignmentDisplayMode", foreign_key: "display_mode_id"

  # has_many :questions, through: :asm_qns, source: :qn, source_type: "Question", dependent: :destroy
  # has_many :coding_questions, through: :asm_qns, source: :qn, source_type: "CodingQuestion", dependent: :destroy

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

  #TODO
  def can_start?(curr_user_course)
    # if open_at > Time.now
    #   return  false, "Mission hasn't open yet :)"
    # end
    # if dependent_on
    #   sbm = Submission.where(mission_id: dependent_mission, std_course_id: curr_user_course).first
    #   if !sbm || sbm.attempting?
    #     return false, "You need to complete #{dependent_mission.title} to unlock this mission :|"
    #   end
    # end
    # return true, ""
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

  #TODO
  def mark_refresh_autograding
    # Thread.new {
    #   submissions.each do |s|
    #     s.submission_gradings.each do |sg|
    #       sg.update_attribute(:autograding_refresh, true)
    #     end
    #   end
    # }
  end

  #TODO

  #TODO
  alias_method :sbms, :submissions
end
