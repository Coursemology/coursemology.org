class UserAchievement < ActiveRecord::Base
  attr_accessible :achievement_id, :user_course_id

  belongs_to :user_course
  belongs_to :achievement

  def update_date
    # update achievement gain date to submission date(not grading date)
    unless achievement && user_course
      return
    end

    lastest_submission_date = nil
    achievement.requirements.asm_req.each do |req|
      asm = req.req.asm
      submission = asm.submissions.where(std_course_id: user_course_id).first
      if submission && submission.submitted_at
        if !lastest_submission_date || submission.submitted_at > lastest_submission_date
          lastest_submission_date = submission.submitted_at
        end
      end
    end

    if lastest_submission_date
      self.updated_at = lastest_submission_date
    end
  end
end
