class CodingQuestion < ActiveRecord::Base
  include Commentable

  attr_accessible :creator_id, :step_name, :description,:max_grade, :staff_comments, :data

  belongs_to :creator, class_name: "User"

  has_many  :std_coding_answers, foreign_key: "qn_id", dependent: :destroy
  has_many  :asm_qns, as: :qn, dependent: :destroy

  has_many :comments, as: :commentable
  has_one :pending_comments, as: :answer

  def data_hash
    JSON.parse(self.data)
  end
end
