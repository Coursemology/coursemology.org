class UserAchievement < ActiveRecord::Base
  attr_accessible :achievement_id, :user_course_id

  belongs_to :user_course
  belongs_to :achievement

  def update_date
    # update achievement gain date to submission date(not grading date)
    submissions = Assessment::Submission.joins(
        "INNER JOIN assessments
            ON assessments.id = assessment_submissions.assessment_id
            AND assessment_submissions.std_course_id = #{ user_course_id }
        INNER JOIN asm_reqs
            ON asm_reqs.asm_id = assessments.id
        INNER JOIN (SELECT requirements.req_id FROM requirements
            WHERE requirements.obj_id = #{ achievement.id }
            AND requirements.obj_type = 'Achievement'
            AND requirements.req_type = 'AsmReq') req
            ON req.req_id = asm_reqs.id")

    lastest_submission_date = nil
    submissions.each do |submission|
      if submission.submitted_at &&
          (!lastest_submission_date ||
              submission.submitted_at > lastest_submission_date)
        lastest_submission_date = submission.submitted_at
      end
    end
    self.updated_at = lastest_submission_date if lastest_submission_date
  end
end
