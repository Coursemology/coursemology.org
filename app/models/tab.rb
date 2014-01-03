class Tab < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :course_id, :owner_type, :title, :description, :order

  belongs_to :course
  has_many :trainings

end
