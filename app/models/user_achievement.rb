class UserAchievement < ActiveRecord::Base
  attr_accessible :achievement_id, :user_course_id

  belongs_to :user_course
  belongs_to :achievement

  def update_date
    # update achievement gain date to submission date(not grading date)
    assessments = Assessment.joins(
        "INNER JOIN asm_reqs
            ON asm_reqs.asm_id = assessments.id
        INNER JOIN (SELECT requirements.req_id FROM requirements
            WHERE requirements.obj_id = #{ achievement.id }
            AND requirements.obj_type = 'Achievement'
            AND requirements.req_type = 'AsmReq') req
            ON req.req_id = asm_reqs.id")

    submissions = Assessment::Submission
        .where(std_course_id: user_course_id, assessment_id: assessments)
        .order("submitted_at DESC")
    self.updated_at = submissions.first.submitted_at || updated_at
  end
end
