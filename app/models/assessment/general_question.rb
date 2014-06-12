class Assessment::GeneralQuestion < ActiveRecord::Base
  acts_as_paranoid
  is_a :question, as: :as_question

end