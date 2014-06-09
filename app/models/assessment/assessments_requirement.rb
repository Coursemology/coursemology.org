class Assessment::AssessmentsRequirement < ActiveRecord::Base
  has_one :assessment, class_name: 'Assessment::Assessment'
  has_many :requirement, class_name: 'Requirement', foreign_key: :obj_id, conditions: { requirements: { obj_type: Assessment::AssessmentsRequirement } }
end
