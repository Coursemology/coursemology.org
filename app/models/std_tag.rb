class StdTag < ActiveRecord::Base
  attr_accessible :exp, :std_course_id, :tag_id

  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :tag
end
