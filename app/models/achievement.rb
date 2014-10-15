class Achievement < ActiveRecord::Base
  acts_as_paranoid
  acts_as_duplicable
  acts_as_sortable

  default_scope { order("position") }

  include Rails.application.routes.url_helpers
  include ActivityObject
  include HasRequirement
  include AsRequirement

  attr_accessible :course_id, :creator_id, :description, :icon_url, :title, :requirement_text, :auto_assign, :published, :position

  validates :title, presence: true

  belongs_to :course
  belongs_to :creator, class_name: "User"

  has_many :user_achievements, dependent: :destroy
  has_many :user_courses, through: :user_achievements

  after_save :check_and_reward, if: :rewarding_changed?

  def rewarding_changed?
    published_changed? or auto_assign_changed?
  end

  def fulfilled_conditions?(user_course)
    # consider achievement with no requirement a special case
    # it can only be assigned manually, since there is no condition to check
    if !published || !requirements || requirements.count == 0 || !auto_assign
      return false
    end

    satisfied = true
    requirements.each do |req|
      satisfied &&= req.satisfied?(user_course)
      unless satisfied
        break
      end
    end
     satisfied
  end

  def get_title
     "Achievement #{title}"
  end

  def get_path
     course_achievement_path(course, self)
  end

  def update_requirement(remaining_reqs, new_reqs)
    # cleanup existing requirement
    remaining_reqs ||= []
    remaining_reqs = remaining_reqs.collect { |id| id.to_i }
    current_reqs = self.requirements.collect { |req| req.id }
    removed_ids = current_reqs - remaining_reqs
    Requirement.delete(removed_ids)

    # add new requirements
    new_reqs ||= []
    new_reqs.each do |new_req|
      self.requirements.build(JSON.parse(new_req))
    end
  end

  def check_and_reward
    Delayed::Job.enqueue(BackgroundJob.new(course_id, :reward_achievement, Achievement.name, self.id))
  end
end
