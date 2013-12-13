class Comic < ActiveRecord::Base

  attr_accessible :visible, :chapter, :name, :episode, :dependent_mission_id, :next_mission_id

  scope :published, where(:visible => true)

  belongs_to :course
  belongs_to :dependent_mission, class_name: "Mission", foreign_key: "dependent_mission_id"
  belongs_to :next_mission, class_name: "Mission", foreign_key: "next_mission_id"

  has_many :comic_pages

end
