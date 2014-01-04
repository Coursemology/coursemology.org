class Tab < ActiveRecord::Base
  default_scope { order(:pos) }
  # attr_accessible :title, :body
  attr_accessible :course_id, :owner_type, :title, :description, :pos

  belongs_to :course
  has_many :trainings

end
