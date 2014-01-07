class Assessment::AssessmentsRequirement < ActiveRecord::Base
  has_one :assessment, class_name: 'Assessment::Assessment'
  belongs_to :requirement, class_name: 'Requirement'
end
