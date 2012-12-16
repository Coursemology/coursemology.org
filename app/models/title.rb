class Title < ActiveRecord::Base
  attr_accessible :course_id, :creator_id, :description, :title

  belongs_to :course
end
