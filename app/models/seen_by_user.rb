class SeenByUser < ActiveRecord::Base
  attr_accessible :obj_id, :obj_type, :user_course_id

  scope :missions, where(obj_type: "Mission")
  scope :trainings, where(obj_type: "Training")
  scope :announcements, where(obj_type: "Announcement")

  belongs_to :user_course
  belongs_to :obj, polymorphic: true
end
