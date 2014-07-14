class Assessment::AnswerGrading < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :answer_id, :grade

  belongs_to :grader, class_name: UserCourse, foreign_key: :grader_course_id
  belongs_to :answer, class_name: Assessment::Answer, foreign_key: :answer_id
  belongs_to :grading, class_name: Assessment::Grading, foreign_key: :grading_id


end