class Assessment::CodingQuestion < ActiveRecord::Base
  is_a :question, as: 'as_assessment_question', class_name: 'Assessment::Question'

  has_one :depends_on, class_name: 'Assessment::CodingQuestion'
  has_one :comment_topic, as: :topic

  attr_accessible :title, :description, :max_grade, :language, :time_limit, :memory_limit, :test_limit, :auto_graded, :data, :depends_on_id
end
