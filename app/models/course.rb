class Course < ActiveRecord::Base
  attr_accessible :creator_id, :description, :title

  belongs_to :creator, class_name: "User"
end
