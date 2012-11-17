class Announcement < ActiveRecord::Base
  attr_accessible :course_id, :creator_id, :description, :important, :publish_at, :title

  belongs_to :course
  belongs_to :creator, class_name: "User"

end
