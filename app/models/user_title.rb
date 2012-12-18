class UserTitle < ActiveRecord::Base
  attr_accessible :is_using, :title_id, :user_course_id

  belongs_to :user_course
  belongs_to :title
end
