class SurveyQuestionType < ActiveRecord::Base
  attr_accessible :title, :description

  scope :MCQ, where(title: 'MCQ')
  scope :MRQ, where(title: 'MRQ')
  scope :Essay, where(title: 'Essay')

end
