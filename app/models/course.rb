class Course < ActiveRecord::Base
  attr_accessible :creator_id, :description, :logo_url, :title

  belongs_to :creator, class_name: "User"

  has_many :missions
  has_many :announcements
  has_many :user_courses
  has_many :trainings
  has_many :quizzes

  has_many :levels
  has_many :achievements

  has_many :enroll_requests
end
