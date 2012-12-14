class SubmissionGrading < ActiveRecord::Base
  attr_accessible :comment, :grader_id, :publish_at, :sbm_id, :sbm_type, :total_grade

  has_many :answer_gradings
  belongs_to :grader, class_name: "User"
  belongs_to :sbm, polymorphic: true

  def get_name
    if self.grader
      return "#{self.grader.name} (#{self.id})"
    else
      return "Auto (#{self.id})"
    end
  end
end
