class Assessment::AutoGradingKeywordOption < ActiveRecord::Base
  validates :keyword, format: {
    with: /[\w\d]+/i,
    message: "%{value} should be a single alphanumeric word."
  }
  validates :score, numericality: { greater_than_or_equal_to: 1 }

  attr_accessible :general_question_id
  attr_accessible :keyword, :score

  belongs_to :general_question
end
