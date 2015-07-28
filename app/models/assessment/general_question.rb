class Assessment::GeneralQuestion < ActiveRecord::Base
  acts_as_paranoid
  is_a :question, as: :as_question, class_name: "Assessment::Question"

  attr_accessible :creator_id, :dependent_id
  attr_accessible :title, :description, :max_grade, :attempt_limit, :staff_comments
  attr_accessible :auto_graded, :auto_grading_type

  as_enum :auto_grading_type, none: 0, exact: 1, keyword: 2

  has_many :auto_grading_exact_options, dependent: :destroy, class_name: Assessment::AutoGradingExactOption.name
  attr_accessible :auto_grading_exact_options_attributes
  accepts_nested_attributes_for :auto_grading_exact_options, allow_destroy: true

  has_many :auto_grading_keyword_options, dependent: :destroy, class_name: Assessment::AutoGradingKeywordOption.name
  attr_accessible :auto_grading_keyword_options_attributes
  accepts_nested_attributes_for :auto_grading_keyword_options, allow_destroy: true

  amoeba do
    include_field :auto_grading_exact_options
    include_field :auto_grading_keyword_options
  end
end
