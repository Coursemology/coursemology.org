class CodingQuestion < ActiveRecord::Base
  attr_accessible :creator_id, :description,:max_grade, :staff_comments, :data, :include_sol_qn_id, :is_auto_grading, :title

  include AssessmentModule

  belongs_to :creator, class_name: "User"

  has_many  :std_coding_answers, foreign_key: "qn_id", dependent: :destroy
  has_many  :asm_qns, as: :qn, dependent: :destroy

  has_one :comment_topic, as: :topic
  belongs_to :include_sol_qn, class_name: "CodingQuestion"

  before_create :set_default_data
  after_update :update_test_limit
  after_save :refresh_asm_autograding, :if => :data_changed?

  def data_hash
    JSON.parse(self.data)
  end

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
