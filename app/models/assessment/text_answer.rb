class Assessment::TextAnswer < ActiveRecord::Base
  is_a :answer, as: 'as_assessment_answer', class_name: 'Assessment::Answer'

  attr_accessible :text
end