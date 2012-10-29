class StudentAnswer < ActiveRecord::Base
  attr_accessible :answer_id, :note, :started_at, :submitted_at

  belongs_to :answer
  belongs_to :creator, through: :answer
end
