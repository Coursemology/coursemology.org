class Assessment::Question < ActiveRecord::Base
  acts_as_superclass

  belongs_to :assessment
end
