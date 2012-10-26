class Course < ActiveRecord::Base
  attr_accessible :creator_id, :description, :title
end
