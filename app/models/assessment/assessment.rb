class Assessment::Assessment < ActiveRecord::Base
  acts_as_superclass as: :as_assessment_assessment

  has_and_belongs_to_many :tags, class_name: Tag, join_table: :assessment_assessments_tags
  has_many :assessment_requirements, class_name: Assessment::AssessmentsRequirement, dependent: :destroy
  has_many :requirements, class_name: Requirement, through: :assessment_requirements
  belongs_to :course, class_name: 'Course'
  belongs_to :creator, class_name: 'User'

  has_many :questions, class_name: Assessment::Question, order: 'pos ASC' do
    def coding
      where(as_assessment_question_type: Assessment::CodingQuestion)
    end

    def before(question)
      where(pos: ['< ?', question.pos])
    end
  end
  has_many :submissions, class_name: Assessment::Submission do
    def final(student_course)
      last = where(std_course_id: student_course).last
      last = last.specific if last
      # self.sbms.find_by_std_course_id(std_course_id)
    end
  end

  alias :as_requirements :requirements

  # @deprecated
  def is_file_submission
    file_submission?
  end

  # @deprecated
  def single_question
    questions.count <= 1
  end
  alias_method :single_question?, :single_question
end
