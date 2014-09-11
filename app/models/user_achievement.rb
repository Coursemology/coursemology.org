class UserAchievement < ActiveRecord::Base
  attr_accessible :achievement_id, :user_course_id

  after_create :set_obtained_at

  belongs_to :user_course
  belongs_to :achievement

  def assign_obtained_date
    # update achievement obtained date to submission date(not grading date)
    submission = Assessment.joins(:as_asm_reqs)
        .where("asm_reqs.id IN (?)", achievement.requirements.asm_req.pluck(:req_id)).submissions
        .where(std_course_id: user_course_id)
        .order("submitted_at DESC").first
    self.obtained_at = submission.submitted_at || obtained_at if submission
  end

  def set_obtained_at
    self.obtained_at = created_at
  end
end
