class WrittenQuestion < ActiveRecord::Base
  attr_accessible :assignment_id, :creator_id, :description, :order
end
