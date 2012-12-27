class Achievement < ActiveRecord::Base
  attr_accessible :course_id, :creator_id, :description, :icon_url, :title

  belongs_to :course
  belongs_to :creator, class_name: "User"

  has_many :requirements, as: :obj
  has_many :ach_reqs, class_name: "Requirement", as: :obj, conditions: { req_type: "Achievement" }
  has_many :asm_reqs, class_name: "Requirement", as: :obj, conditions: { req_type: "AsmReq" }
  has_one  :lvl_req, class_name: "Requirement", as: :obj, conditions: { req_type: "Level" }

  def fulfilled_conditions?(user_course)
    puts "#{id} Check fulfill all conditions", self.to_json
    satisfied = true
    requirements.each do |req|
      satisfied &&= req.satisfied?(user_course)
      if not satisfied
        break
      end
    end
    return satisfied
  end
end
