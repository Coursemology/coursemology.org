class Assessment::Mission < ActiveRecord::Base
  is_a :assessment, as: 'as_assessment_assessment', class_name: 'Assessment::Assessment'

  has_one :dependent, class_name: 'Assessment::Mission'
end
