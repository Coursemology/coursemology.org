class DuplicateLog < ActiveRecord::Base
  attr_accessible :dest_course_id, :dest_obj_id, :dest_obj_type, :origin_course_id, :origin_obj_id, :origin_obj_type, :user_id

  belongs_to :user
  belongs_to :origin_course, class_name: "Course"
  belongs_to :origin_obj, polymorphic: true
  belongs_to :dest_course, class_name: "Course"
  belongs_to :dest_obj, polymorphic: true
end
