class Assessment::Training < ActiveRecord::Base
  acts_as_paranoid
  is_a :assessment, as: :as_assessment, class_name: "Assessment"

  attr_accessible :skippable

  #TODO, fix
  attr_accessible :exp, :bonus_exp
  attr_accessible :title, :description
  attr_accessible :published, :comment_per_qn
  attr_accessible :open_at, :close_at, :bonus_cutoff_at
  attr_accessible :tab_id, :display_mode_id, :dependent_on_ids
  attr_accessible :dependent_on, :dependent_on_attributes

  validates_presence_of :title, :exp, :open_at

  validates_with DateValidator, fields: [:open_at, :bonus_cutoff_at]

  def full_title
    "#{I18n.t('Assessment.Training')} : #{self.title}"
  end

  def get_path
    course_assessment_training_path(self.course, self)
  end
end
