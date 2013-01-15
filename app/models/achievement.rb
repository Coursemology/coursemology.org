class Achievement < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ActivityObject

  attr_accessible :course_id, :creator_id, :description, :icon_url, :title

  belongs_to :course
  belongs_to :creator, class_name: "User"

  has_many :requirements, as: :obj, dependent: :destroy
  has_many :requirement_of, class_name: "Requirement", as: :req, dependent: :destroy
  has_many :ach_reqs, class_name: "Requirement", as: :obj, conditions: { req_type: "Achievement" }
  has_many :asm_reqs, class_name: "Requirement", as: :obj, conditions: { req_type: "AsmReq" }
  has_one  :lvl_req, class_name: "Requirement", as: :obj, conditions: { req_type: "Level" }

  def fulfilled_conditions?(user_course)
    satisfied = true
    requirements.each do |req|
      satisfied &&= req.satisfied?(user_course)
      if not satisfied
        break
      end
    end
    return satisfied
  end

  def get_title
    return "Achievement #{title}"
  end

  def get_path
    return course_achievement_path(course, self)
  end

  def update_requirement(remaining_reqs, new_reqs)
    # cleanup existing requirement
    remaining_reqs ||= []
    remaining_reqs = remaining_reqs.collect { |id| id.to_i }
    current_reqs = self.requirements.collect { |req| req.id }
    removed_ids = current_reqs - remaining_reqs
    Requirement.delete(removed_ids)

    puts self.requirements.to_json

    # add new requirements
    new_reqs ||= []
    new_reqs.each do |new_req|
      self.requirements.build(JSON.parse(new_req))
    end
    self.save
    puts self.requirements.to_json
  end
end
