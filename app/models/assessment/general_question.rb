class Assessment::GeneralQuestion < ActiveRecord::Base
  acts_as_paranoid
  is_a :question, as: :as_question, class_name: "Assessment::Question"

  attr_accessible :creator_id, :dependent_id
  attr_accessible :title, :description, :max_grade, :attempt_limit, :staff_comments
  attr_accessible :auto_graded

end