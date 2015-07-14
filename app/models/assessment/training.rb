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
  validates_numericality_of :bonus_exp

  validate :bonus_cutoff_time_must_be_valid

  def full_title
    "#{I18n.t('Assessment.Training')} : #{self.title}"
  end

  def get_path
    course_assessment_training_path(self.course, self)
  end

  private

  def bonus_cutoff_time_must_be_valid
    return if !bonus_exp || bonus_exp == 0

    unless bonus_cutoff_at && bonus_cutoff_at > open_at
      errors[:bonus_cutoff_at] << "must be after open time"
    end
  end
end
