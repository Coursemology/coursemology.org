class Assessment::Answer < ActiveRecord::Base
  acts_as_superclass as: :as_assessment_answer

  has_one :comment_topic, as: :topic
  has_one :grading, class_name: Assessment::Grading

  belongs_to :submission
  belongs_to :question
end
