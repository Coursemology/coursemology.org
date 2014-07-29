class Assessment::Mission < ActiveRecord::Base
  acts_as_paranoid
  is_a :assessment, as: :as_assessment, class_name: "Assessment"

  include Rails.application.routes.url_helpers

  attr_accessible :file_submission,
                  :file_submission_only

  attr_accessible  :title, :description, :exp, :open_at, :close_at, :published, :comment_per_qn,
                   :dependent_id, :display_mode_id


  #TODO
  validates_with DateValidator, fields: [:open_at, :close_at]

  def full_title
    "#{I18n.t('Assessment.Mission')} : #{self.title}"
  end

  def total_exp
    exp
  end

  def get_path
    course_assessment_mission_path(self.course, self)
  end

  def single_question?
    questions.count == 1
  end

  def missions_dep_on_published
    missions_dependent_on.where(publish:true)
  end

  def current_exp
    exp
  end

  #TODO: refactor
  def self.reflect_on_association(association)
    super || self.parent.reflect_on_association(association)
  end

end
