class Assessment::Training < ActiveRecord::Base
  acts_as_paranoid
  is_a :assessment, as: :as_assessment

  attr_accessible :bonus_cutoff_at

  validates_with DateValidator, fields: [:open_at, :bonus_cutoff_at]
end
