class Annotation < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :annotable_id, :annotable_type, :text, :user_course_id, :line_start, :line_end, :updated_at
  include Commenting

  belongs_to :user_course
  belongs_to :annotable, polymorphic: true

  def commentable
    annotable
  end
end
