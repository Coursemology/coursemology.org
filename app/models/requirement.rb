class Requirement < ActiveRecord::Base
  attr_accessible :obj_id, :obj_type, :req_id, :req_type

  belongs_to :obj, polymorphic: true
  belongs_to :req, polymorphic: true

  scope :ach_obj, where(obj_type: "Achievement")

  scope :ach_req, where(req_type: "Achievement")
  scope :asm_req, where(req_type: "AsmReq")
  scope :lvl_req, where(req_type: "Level")

  def satisfied?(user_course)
    # depends on the kind of requirement
    # level
    # achievement
    case req.class.to_s.to_sym
      when :Achievement
        return check_achievement(user_course)
      when :AsmReq
        return req.satisfied?(user_course)
      when :Level
        return req.satisfied?(user_course)
      else
        return true
    end
  end

  def check_achievement(user_course)
    uach = UserAchievement.find_by_user_course_id_and_achievement_id(
      user_course.id, req.id
    )
    !uach.nil?
  end

  def as_json(options={})
    super(options).reject { |k, v| v.nil? }
  end
end
