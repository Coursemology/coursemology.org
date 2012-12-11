class SubmissionGrading < ActiveRecord::Base
  attr_accessible :comment, :grader_id, :publish_at, :submission_id, :total_grade

  has_many :answer_gradings
  belongs_to :grader, class_name: "User"
  belongs_to :submission

  def get_name
    if self.grader
      return "#{self.grader.name} (#{self.id})"
    else
      return "Auto (#{self.id})"
    end
  end
end
