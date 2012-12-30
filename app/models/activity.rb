class Activity < ActiveRecord::Base
  attr_accessible :action_id, :actor_id, :course_id, :extra, :obj_id, :obj_type, :target_id
end
