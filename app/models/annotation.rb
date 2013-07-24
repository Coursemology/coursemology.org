class Annotation < ActiveRecord::Base
  attr_accessible :annotable_id, :annotable_type, :text, :user_course_id, :line_start, :line_end, :updated_at

  belongs_to :user_course
  belongs_to :annotable, polymorphic: true
end
