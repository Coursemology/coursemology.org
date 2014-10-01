class Assessment::CodingQuestion < ActiveRecord::Base
  acts_as_paranoid
  is_a :question, as: :as_question, class_name: "Assessment::Question"

  attr_accessible :auto_graded
  attr_accessible :language_id, :dependent_id
  attr_accessible :title, :description, :max_grade, :attempt_limit, :staff_comments
  attr_accessible :memory_limit, :time_limit, :tests,
                  :template, :pre_include, :append_code

  belongs_to  :language, class_name: "ProgrammingLanguage"

  after_save :refresh_asm_autograding, :if => :eval_attributes_changed?
  before_create :set_default_values

  def eval_attributes_changed?
    memory_limit_changed? || time_limit_changed? ||
        pre_include_changed? || append_code_changed? ||
        tests_changed?
  end

  def coding_answers
    Assessment::CodingAnswer.
        joins("INNER JOIN assessment_answers aa
                  ON aa.as_answer_id = assessment_coding_answers.id AND aa.as_answer_type = 'Assessment::CodingAnswer'
               INNER JOIN (SELECT aq.id FROM assessment_questions aq INNER JOIN assessment_coding_questions acq
                  ON aq.as_question_id = acq.id AND aq.as_question_type = 'Assessment::CodingQuestion'
                  WHERE acq.id = #{self.id}) aacq ON aacq.id = aa.question_id")
  end

  def data_hash
    JSON.parse(self.tests)
  end

  def refresh_asm_autograding
    if question_assessments.first
      question_assessments.first.assessment.mark_refresh_autograding
    end
  end

  def self.reflect_on_association(association)
    super || self.parent.reflect_on_association(association)
  end

  private

  def set_default_values
    self.memory_limit = 1 unless memory_limit
    self.time_limit = 1 unless time_limit
    self.attempt_limit = 0 unless attempt_limit
  end
end
