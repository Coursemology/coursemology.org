class Course < ActiveRecord::Base
  attr_accessible :creator_id, :description, :logo_url, :title

  belongs_to :creator, class_name: "User"

  has_many :assignments
  has_many :announcements
  has_many :user_courses
  has_many :trainings
end
