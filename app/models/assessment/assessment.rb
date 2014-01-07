class Assessment::Assessment < ActiveRecord::Base
  acts_as_superclass

  has_and_belongs_to_many :tags, class_name: Tag, join_table: :assessment_assessments_tags
  has_many :requirements, class_name: Requirement
  belongs_to :course, class_name: 'Course'
  belongs_to :creator, class_name: 'User'
end
