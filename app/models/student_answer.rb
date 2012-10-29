class StudentAnswer < ActiveRecord::Base
  attr_accessible :answer_id, :note, :started_at, :submitted_at
end
