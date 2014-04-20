class SurveyQuestionOption < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :question_id, :description, :pos, :count

  belongs_to :survey_question, foreign_key: "question_id"
  has_one :file, as: :owner, class_name: "FileUpload", dependent: :destroy
  has_many :answers, class_name:"SurveyMrqAnswer", foreign_key: "option_id"


  def increase_count
    if self.count
      self.count += 1
    else
      self.count = 1
    end
    self.save
  end

  def decrease_count
    if self.count and self.count > 0
      self.count -= 1
    else
      self.count = 0
    end
    self.save
  end

  def get_count(include_phantom)
    if include_phantom
      count
    else
      answers.includes(:user_course).where("user_courses.is_phantom = 0 and user_courses.role_id = 5").count
    end
  end
end
