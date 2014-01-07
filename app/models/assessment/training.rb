class Assessment::Training < ActiveRecord::Base
  is_a :assessment, as: 'as_assessment_assessment', class_name: 'Assessment::Assessment'
end
