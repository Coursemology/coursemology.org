class Tag < ActiveRecord::Base
  attr_accessible :course_id, :description, :icon_url, :max_exp, :name

  belongs_to :course
end
