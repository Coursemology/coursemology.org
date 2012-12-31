class Activity < ActiveRecord::Base
  attr_accessible :action_id, :actor_id, :course_id, :extra, :obj_id, :obj_type, :target_id

  belongs_to :course
  belongs_to :action
  belongs_to :actor, class_name: "User"
  belongs_to :target, class_name: "User"
  belongs_to :obj, polymorphic: true

  def self.attempted_asm(user_course, asm)
    action = Action.find_by_text("attempted")
    Activity.add(user_course.course, user_course.user, action, asm, nil, nil)
  end

  def self.started_asm(user_course, asm)
    action = Action.find_by_text("started")
    Activity.add(user_course.course, user_course.user, action, asm, nil, nil)
  end

  def self.earned_smt(user_course, obj)
    action = Action.find_by_text("earned")
    Activity.add(user_course.course, user_course.user, action, obj, nil, nil)
  end

  private
  def self.add(course, actor, action, obj, target, extra)
    act = Activity.new
    act.course = course
    act.actor = actor
    act.action = action
    act.obj = obj
    act.target = target
    act.extra = extra
    act.save
  end
end
