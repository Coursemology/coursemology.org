class CodingQuestion < ActiveRecord::Base
  attr_accessible :creator_id, :step_name, :description,:max_grade, :staff_comments, :data, :include_sol_qn_id, :is_auto_grading

  belongs_to :creator, class_name: "User"

  has_many  :std_coding_answers, foreign_key: "qn_id", dependent: :destroy
  has_many  :asm_qns, as: :qn, dependent: :destroy

  has_one :comment_topic, as: :topic
  belongs_to :include_sol_qn, class_name: "CodingQuestion"

  before_create :set_default_data

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
end
