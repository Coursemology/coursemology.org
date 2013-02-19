class Comment < ActiveRecord::Base
  attr_accessible :commentable_id, :commentable_type, :text, :user_course_id

  belongs_to :user_course
  belongs_to :commentable, polymorphic: true
end
