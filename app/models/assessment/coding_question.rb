class Assessment::CodingQuestion < ActiveRecord::Base
  is_a :question, as: 'as_assessment_question', class_name: 'Assessment::Question'

  has_one :depends_on, class_name: 'Assessment::CodingQuestion'
  has_one :comment_topic, as: :topic

  attr_accessible :title, :description, :max_grade, :language, :time_limit, :memory_limit, :test_limit, :auto_graded, :data, :depends_on_id

  alias_attribute :is_auto_grading?, :auto_graded?

  def build_answer
    Assessment::CodingAnswer.new({
                                    question_id: self.question.id,
                                    code: prefill
                                 }, without_protection: true)
  end

private
  # TODO: Factor this out to a project provider.
  def prefill

  end
end
