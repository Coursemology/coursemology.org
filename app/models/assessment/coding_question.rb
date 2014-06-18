class Assessment::CodingQuestion < ActiveRecord::Base
  acts_as_paranoid
  is_a :question, as: :as_question, class_name: "Assessment::Question"

  attr_accessible :language_id

  belongs_to  :dependent_on, class_name: "Assessment::CodingQuestion", foreign_key: "dependent_id"
  belongs_to  :language, class_name: "ProgrammingLanguage"

  before_create :set_default_data
  after_update :update_test_limit
  after_save :refresh_asm_autograding, :if => :data_changed?

  def data_hash
    JSON.parse(self.data)
  end

  #TODO
  def set_default_data
    unless self.data
      self.data = '{"type":"do","language":"python","prefill":""}'
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

  def test_limit
    data_hash["testLimit"] || 0
  end

  def update_test_limit
    if changed_attributes.has_key? "data"
      old_data_hash = JSON.parse(changed_attributes["data"])
      diff = test_limit.to_i - old_data_hash["testLimit"].to_i
      if  diff != 0
        Thread.start {
          std_coding_answers.each do |std_answer|
            std_answer.test_left = [0, std_answer.test_left + diff].max
            std_answer.save
          end
        }
      end
    end
  end


  def refresh_asm_autograding
    if asm_qns.first
      asm_qns.first.asm.mark_refresh_autograding
    end
  end
end
