class Activity < ActiveRecord::Base
  attr_accessible :action_id, :actor_course_id, :course_id, :extra, :obj_id,
      :obj_type, :target_course_id

  belongs_to :course
  belongs_to :action
  belongs_to :actor_course, class_name: "UserCourse"
  belongs_to :target_course, class_name: "UserCourse"
  belongs_to :obj, polymorphic: true

  default_scope includes(:obj, :action, :actor_course=>:user)

  def self.attempted_asm(user_course, asm)
    action = Action.find_by_text("attempted")
    Activity.add(user_course.course, user_course, action, asm, nil, nil)
  end

  def self.started_asm(user_course, asm)
    action = Action.find_by_text("started")
    Activity.add(user_course.course, user_course, action, asm, nil, nil)
  end

  def self.earned_smt(user_course, obj)
    action = Action.find_by_text("earned")
    Activity.add(user_course.course, user_course, action, obj, nil, nil)
  end

  def self.reached_lvl(user_course, obj)
    action = Action.find_by_text("reached")
    Activity.add(user_course.course, user_course, action, obj, nil, nil)
  end

  def self.created_forum_topic(user_course, topic)
    action = Action.find_by_text('created Forum topic')
    Activity.add(user_course.course, user_course, action, topic, nil, nil)
  end

  def self.asked_question(user_course, topic)
    action = Action.find_by_text('asked')
    Activity.add(user_course.course, user_course, action, topic, nil, nil)
  end

  def self.replied_post(user_course, post)
    action = Action.find_by_text('replied to')
    Activity.add(user_course.course, user_course, action, post, nil, nil)
  end

  def self.voted_forum_post(user_course, post)
    action = Action.find_by_text('voted on')
    Activity.add(user_course.course, user_course, action, post, nil, nil)
  end

private
  def self.add(course, actor_course, action, obj, target_course, extra)
    act = Activity.new
    act.course = course
    act.actor_course = actor_course
    act.action = action
    act.obj = obj
    act.target_course = target_course
    act.extra = extra
    act.save
  end
end
