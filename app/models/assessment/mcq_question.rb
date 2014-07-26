class Assessment::McqQuestion < ActiveRecord::Base
  acts_as_paranoid
  is_a :question, as: :as_question, class_name: "Assessment::Question"

  attr_accessible :creator_id, :dependent_id
  attr_accessible :title, :description, :max_grade, :attempt_limit, :staff_comments

  has_many  :options, class_name: Assessment::McqOption, dependent: :destroy, foreign_key: "question_id"
  attr_accessible :select_all

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
end