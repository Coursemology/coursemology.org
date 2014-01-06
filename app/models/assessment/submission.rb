class Assessment::Submission < ActiveRecord::Base
  acts_as_superclass

  belongs_to :assessment
  belongs_to :course, class_name: 'Course'
end
