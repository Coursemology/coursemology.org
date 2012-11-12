class Announcement < ActiveRecord::Base
  attr_accessible :course_id, :creator_id, :important, :publish_at

  belongs_to :course
  belongs_to :creator, class_name: "User"

end
