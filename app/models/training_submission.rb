class TrainingSubmission < ActiveRecord::Base
  attr_accessible :current_step, :open_at, :student_id, :submit_at, :training_id

  belongs_to :student, class_name: "User"
  belongs_to :training

  has_many :sbm_answers, as: :sbm
  has_many :std_mcq_anwers, through: :sbm_answers,
      source: :answer, source_type: "StdMcqAnswer"
end
