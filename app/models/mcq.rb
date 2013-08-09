class Mcq < ActiveRecord::Base
  include Commentable

  attr_accessible :correct_answers, :correct_answer_id, :creator_id, :description, :max_grade, :order, :select_all

  belongs_to :creator, class_name: "User"

  has_many :comments, as: :commentable
  has_one :pending_comments, as: :answer

  has_many :mcq_answers, dependent: :destroy
  has_many :std_mcq_answers, dependent: :destroy
  has_many :asm_qns, as: :qn, dependent: :destroy
end
