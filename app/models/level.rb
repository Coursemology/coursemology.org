class Level < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ActivityObject

  attr_accessible :course_id, :creator_id, :exp_threshold, :level

  belongs_to :course

  has_many :user_courses

  def get_title
    return "Level #{level - 1}"
  end

  def get_path
    return course_levels_path(course)
  end
end
