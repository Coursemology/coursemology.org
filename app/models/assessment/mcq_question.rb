class Assessment::McqQuestion < ActiveRecord::Base
  acts_as_paranoid
  acts_as_duplicable
  is_a :question, as: :as_question, class_name: "Assessment::Question"

  attr_accessible :creator_id, :dependent_id
  attr_accessible :title, :description, :max_grade, :attempt_limit, :staff_comments

  has_many  :options, class_name: Assessment::McqOption, dependent: :destroy, foreign_key: "question_id"
  attr_accessible :select_all

  amoeba do
    include_field :options
  end

  def mcq_answers(filters)

    Assessment::McqAnswer.
        joins("INNER JOIN assessment_answers
                  ON assessment_answers.as_answer_id = assessment_mcq_answers.id AND
                    assessment_answers.as_answer_type = 'Assessment::McqAnswer'
               INNER JOIN (SELECT aq.id FROM assessment_questions aq INNER JOIN assessment_mcq_questions acq
                  ON aq.as_question_id = acq.id AND aq.as_question_type = 'Assessment::McqQuestion'
                  WHERE acq.id = #{self.id}) aacq ON aacq.id = assessment_answers.question_id").
        where("assessment_answers.std_course_id = ? AND assessment_answers.submission_id = ?",
              filters[:std_course_id], filters[:submission_id])
  end

  # Returns all answers and their attempt times in an array
  # Example return value:
  #   [ { answer: answer_1, attempt: 1 }, { answer: answer_2, attempt: 3 } ]
  def mcq_answer_with_attempts(submission)
    answers = mcq_answers(std_course_id: submission.std_course,
                          submission_id: submission).includes(:options)
    options_hash = {}
    answers.each do |answer|
      update_attempt_times(options_hash, answer)
    end
    options_hash.values
  end

  private

  def update_attempt_times(hash, answer)
    key = answer.options.pluck(:id)
    if hash[key] && hash[key][:answer]
      hash[key][:answer] = answer
      hash[key][:attempt] += 1
    else
      hash[key] = { answer: answer, attempt: 1 }
    end
  end
end