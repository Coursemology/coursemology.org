class FileUpload < ActiveRecord::Base
  attr_accessible :course_id, :creator_id, :file, :course, :creator

  belongs_to :course
  belongs_to :creator, class_name: "User"

  has_attached_file :file
end
