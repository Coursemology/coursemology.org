class UserAchievement < ActiveRecord::Base
  attr_accessible :achievement_id, :user_course_id
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
end
