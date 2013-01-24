class Reward < ActiveRecord::Base
  include HasRequirement

  attr_accessible :course_id, :creator_id, :description, :icon_url, :title

  belongs_to :course
end
