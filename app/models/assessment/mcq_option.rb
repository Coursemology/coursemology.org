class McqOption < ActiveRecord::Base
  belongs_to :creator, class_name: 'User'
  belongs_to :question, class_name: 'McqQuestion'
end
