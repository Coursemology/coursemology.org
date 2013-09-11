class Survey < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :course_id, :title, :creator_id, :description,
                  :open_at, :expire_at, :anonymous, :publish,
                  :allow_modify, :has_section

  belongs_to :course
  belongs_to :creator, class_name: "User"

  has_many :survey_sections,    dependent: :destroy
  has_many :survey_questions,   dependent: :destroy
  has_many :survey_submissions


  def questions
    survey_questions
  end

  def can_start?
    open_at >= Time.now
  end

  def submission_by(user_course_id)
    self.survey_submissions.where(user_course_id: user_course_id).first
  end

end
