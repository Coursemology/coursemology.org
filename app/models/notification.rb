class Notification < ActiveRecord::Base
  attr_accessible :action_id, :actor_id, :extra, :obj_id, :obj_type, :target_course_id
  #target_course_id: student_course_id of the target.., not the course_id of the target

  belongs_to :action
  belongs_to :actor, class_name: "User"
  belongs_to :obj, polymorphic: true
  belongs_to :target_course, class_name: "UserCourse"

  def self.leveledup(target_course, level)
    action = Action.find_by_text("reached")
    self.add(target_course, nil, action, level, nil)
  end

  def self.earned_achievement(target_course, ach)
    action = Action.find_by_text("earned")
    self.add(target_course, nil, action, ach, nil)
  end

  private
  def self.add(target_course, actor, action, obj, extra)
    noti = Notification.new
    noti.target_course = target_course
    noti.actor = actor
    noti.action = action
    noti.obj = obj
    noti.extra = extra
    noti.save
  end
end
