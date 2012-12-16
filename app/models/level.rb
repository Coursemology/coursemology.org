class Level < ActiveRecord::Base
  attr_accessible :course_id, :creator_id, :exp_threshold, :level

  belongs_to :course
end
