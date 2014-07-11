class Assessment::CodingQuestion < ActiveRecord::Base
  acts_as_paranoid
  is_a :question, as: :as_question, class_name: "Assessment::Question"

  attr_accessible :language_id, :dependent_id
  attr_accessible :memory_limit, :time_limit, :test_limit, :data, :auto_graded

  belongs_to  :dependent_on, class_name: "Assessment::Question", foreign_key: "dependent_id"
  belongs_to  :language, class_name: "ProgrammingLanguage"

  before_create :set_default_data
  after_update :update_test_limit, if: :test_limit_changed?
  after_save :refresh_asm_autograding, :if => :data_changed?

  def data_hash
    JSON.parse(self.data)
  end

  #TODO
  def set_default_data
    unless self.data
      self.data = '{"type":"do","prefill":""}'
    end
  end

  def prefilled_code
    data_hash["prefill"] || "#Prefilled code \n#Auto generated"
  end

  def included_code
    data_hash["included"] || ""
  end

  def test_code
    data_hash["included"] || ""
  end

  def update_test_limit
    old_tl = changed_attributes[:test_limit] || 0
    diff = test_limit - old_tl
    if diff != 0
      Thread.start {
        std_coding_answers.each do |std_answer|
          std_answer.test_left = [0, std_answer.test_left + diff].max
          std_answer.save
        end
      }
    end
  end


  def refresh_asm_autograding
    if question_assessments.first
      question_assessments.first.assessment.mark_refresh_autograding
    end
  end
end
