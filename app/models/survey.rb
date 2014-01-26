class Survey < ActiveRecord::Base
  acts_as_paranoid
  default_scope { order("open_at") }
  attr_accessible :course_id, :title, :creator_id, :description,
                  :open_at, :expire_at, :anonymous, :publish,
                  :allow_modify, :has_section, :exp

  belongs_to :course
  belongs_to :creator, class_name: "User"

  has_many :survey_sections,    dependent: :destroy
  has_many :survey_questions,   dependent: :destroy
  has_many :survey_submissions


  def submissions
    survey_submissions
  end

  def questions
    survey_questions
  end

  def can_start?
    open_at <= Time.now
  end

  def submission_by(user_course)
    self.survey_submissions.where(user_course_id: user_course).first
  end

  def sections
    survey_sections
  end

  def dup
    clone = super
    map = {}
    survey_sections.each do |section|
      clone_section = section.dup
      clone_section.survey = clone
      clone_section.save
      map[section] = clone_section
    end

    survey_questions.each do |question|
      clone_question = question.dup
      clone_question.survey = clone
      if question.survey_section
        clone_question.survey_section = map[question.survey_section]
      end
      clone_question.save

      question.options.each do |option|
        clone_option = option.dup
        clone_option.survey_question = clone_question
        clone_option.save

        if option.file
          option.file.dup_owner(clone_option)
        end
      end
    end
    clone
  end

end
