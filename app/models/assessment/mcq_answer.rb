class Assessment::McqAnswer < ActiveRecord::Base
  acts_as_paranoid
  is_a :answer, as: :as_answer, class_name: "Assessment::Answer"

  has_many  :answer_options, class_name: Assessment::AnswerOption
  has_many  :options, class_name: Assessment::McqOption, through: :answer_options
end


