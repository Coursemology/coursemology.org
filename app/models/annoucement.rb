class Announcement < ActiveRecord::Base
  attr_accessible :course_id, :creator_id, :publish_at, :important

  belongs_to :course
  belongs_to :creator, class_name: "User"

end
