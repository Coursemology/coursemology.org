class McqAnswer < ActiveRecord::Base
  attr_accessible :creator_id, :explanation, :is_correct, :mcq_id, :text

  belongs_to :creator, class_name: "User"
  belongs_to :mcq

  has_many :std_mcq_answers

  def qn_id
    mcq_id
  end

  def qn
    mcq
  end
end
