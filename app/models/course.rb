class Course < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :creator_id, :description, :logo_url, :title

  belongs_to :creator, class_name: "User"

  has_many :missions
  has_many :announcements
  has_many :user_courses
  has_many :trainings
  has_many :quizzes

  has_many :users, through: :user_courses

  has_many :submissions, through: :user_courses
  has_many :training_submissions, through: :user_courses
  has_many :quiz_submissions, through: :user_courses

  has_many :activities

  has_many :levels
  has_many :achievements

  has_many :enroll_requests

  has_many :tags
  has_many :tag_groups

  def asms
    return missions + quizzes + trainings
  end

  def student_courses
    std = Role.find_by_name("student")
    return self.user_courses.where(role_id: std.id)
  end
end
