class Comment < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :commentable_id, :commentable_type, :comment_topic_id, :text, :user_course_id

  include Commenting

  belongs_to :user_course
  belongs_to :commentable, polymorphic: true
  belongs_to :comment_topic
end
