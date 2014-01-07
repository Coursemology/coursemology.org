class Assessment::Mission < ActiveRecord::Base
  is_a :assessment, as: 'as_assessment_assessment', class_name: Assessment::Assessment

  has_one :dependent, class_name: Assessment::Mission, foreign_key: :id

  # @deprecated
  def get_final_sbm_by_std(std_course_id)
    submissions.final(std_course_id)
  end

  def open?
    return open_at <= Time.now
  end

  def can_start?(curr_user_course)
    return false if not open?

    if dependent
      submission = Assessment::Submission.where(id: dependent.assessment, std_course_id: curr_user_course).first
      return false if !submission || submission.attempting?
    end

    return true
  end
end
