class Comment < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :commentable_id, :commentable_type, :text, :user_course_id

  include Commenting

  belongs_to :user_course
  belongs_to :commentable, polymorphic: true

end
