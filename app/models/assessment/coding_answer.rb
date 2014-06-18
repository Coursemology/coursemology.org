class Assessment::CodingAnswer < ActiveRecord::Base
  acts_as_paranoid
  is_a :answer, as: :as_answer, class_name: "Assessment::Answer"

end
