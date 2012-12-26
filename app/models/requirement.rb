class Requirement < ActiveRecord::Base
  attr_accessible :obj_id, :obj_type, :req_id, :req_type

  belongs_to :obj, polymorphic: true
  belongs_to :req, polymorphic: true

  def satisfied?(user_course)
    # depends on the kind of requirement
    # level
    # achievement
    puts 'requirement obj ', req, req.to_json
    case req
    when Achievement
      return check_achievement(user_course)
    when AsmReq
      puts "Check AsmReq"
      return req.satisfied?(user_course)
    else
      puts "Check level"
      return true
    end

    return false;
  end

  def check_achievement(user_course)
    uach = UserAchievement.find_by_user_course_id_and_achievement_id(
      user_course.id, req.id
    )
    return !uach.nil?
  end
end
