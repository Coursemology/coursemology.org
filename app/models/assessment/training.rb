class Assessment::Training < ActiveRecord::Base
  acts_as_paranoid
  is_a :assessment, as: :as_assessment, auto_join: false, class_name: "Assessment"

  attr_accessible :bonus_cutoff_at, :bonus_exp, :skippable

  validates_with DateValidator, fields: [:open_at, :bonus_cutoff_at]

  def self.reflect_on_association(association)
    super || self.parent.reflect_on_association(association)
  end

  def self.reflect_on_aggregation(name)
    super || self.parent.reflect_on_aggregation(name)
  end

  def column_for_attribute(name)
    super || self.assessment.column_for_attribute(name)
  end
end
