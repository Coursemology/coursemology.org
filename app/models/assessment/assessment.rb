class Assessment::Assessment < ActiveRecord::Base
  acts_as_superclass

  has_and_belongs_to_many :tags, class_name: Tag, join_table: :assessment_assessments_tags
  has_many :assessment_requirements, class_name: AssessmentsRequirement, dependent: :destroy
  has_many :requirements, class_name: Requirement, through: :assessment_requirements
  belongs_to :course, class_name: 'Course'
  belongs_to :creator, class_name: 'User'

  alias :as_requirements :requirements
end
