class Level < ActiveRecord::Base
  acts_as_duplicable
  default_scope { order("level ASC") }

  include Rails.application.routes.url_helpers
  include ActivityObject

  attr_accessible :exp_threshold, :level

  belongs_to :course

  has_many :user_courses

  def get_title
    "Level #{level}"
  end

  def get_path
    course_levels_path(course)
  end

  def next_level
    course.levels.find_by_level(level + 1) || self
  end

  def satisfied?(user_course)
    #user_course.level only get the Level object, same type as self object
    user_course.level && user_course.level.level >= self.level
  end

  def title
    get_title
  end
end
