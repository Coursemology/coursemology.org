class Assessment::GradingLog < ActiveRecord::Base
  acts_as_paranoid

  belongs_to  :grading, class_name: Assessment::Grading
end