class Assessment::Assessment < ActiveRecord::Base
  acts_as_superclass

  belongs_to :course, class_name: 'Course'
  belongs_to :creator, class_name: 'User'
end
