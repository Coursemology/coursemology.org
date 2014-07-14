class Assessment::GradingLog < ActiveRecord::Base
  acts_as_paranoid

  belongs_to  :grading, class_name: Assessment::Grading
  belongs_to  :grader, class_name: UserCourse, foreign_key: :grader_course_id
end