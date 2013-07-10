class TutorialGroup < ActiveRecord::Base
  attr_accessible :course_id, :student_id, :tutor_id

  belongs_to :course

end
