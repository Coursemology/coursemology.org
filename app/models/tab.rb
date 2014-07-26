class Tab < ActiveRecord::Base
  acts_as_duplicable
  default_scope { order(:pos) }
  # attr_accessible :title, :body
  attr_accessible :course_id, :owner_type, :title, :description, :pos


  scope :training, where(owner_type: "Assessment::Training")
  scope :mission, where(owner_type: "Assessment::Mission")

  belongs_to :course
  has_many  :assessments, dependent: :destroy
  has_many  :trainings, through: :assessments, class_name: "Assessment::Training",
            source: :as_assessment, source_type: "Assessment::Training"

end
