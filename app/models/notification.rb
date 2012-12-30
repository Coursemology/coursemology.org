class Notification < ActiveRecord::Base
  attr_accessible :action_id, :actor_id, :extra, :obj_id, :obj_type, :target_course_id
end
