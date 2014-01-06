class Assessment::Mission < ActiveRecord::Base
  belongs_to :assessment
  has_one :dependent, class_name: 'Assessment::Mission'
end
