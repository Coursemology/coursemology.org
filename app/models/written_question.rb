class WrittenQuestion < ActiveRecord::Base
  attr_accessible :assignment_id, :creator_id, :description, :order

  belongs_to :assignment
  belongs_to :creator

  has_many :answers, as: :question
end
