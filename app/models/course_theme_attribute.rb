class CourseThemeAttribute < ActiveRecord::Base
  attr_accessible :course_id, :theme_attribute_id, :value

  belongs_to :theme_attribute
  belongs_to :course
end
