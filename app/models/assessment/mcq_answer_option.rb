class Assessment::McqAnswerOption < ActiveRecord::Base
  belongs_to :option, class_name: Assessment::McqOption
  belongs_to :answer, class_name: Assessment::McqAnswer
end
