class Assessment::Mission < ActiveRecord::Base
  is_a :assessment, as: 'as_assessment_assessment', class_name: 'Assessment::Assessment'

  has_many :dependent, class_name: Assessment::Mission, foreign_key: :id
  has_many :files, as: :owner, class_name: 'FileUpload', dependent: :destroy

  alias :get_all_questions :questions

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
      submission = Assessment::Submission.where(id: dependent.map { |d| d.assessment }, std_course_id: curr_user_course).first
      return false if !submission || (not submission.submitted?)
    end

    return true
  end

  # @deprecated
  def single_question?
    questions.count <= 1
  end
end
