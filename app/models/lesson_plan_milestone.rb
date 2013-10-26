class LessonPlanMilestone < ActiveRecord::Base
  attr_accessible :title, :description, :end_at

  belongs_to :course
  belongs_to :creator, class_name: "User"

  def previous_milestone
    LessonPlanMilestone.where("end_at < :end_at", :end_at => self.end_at).order("end_at DESC").first
  end

  def entries
    # Find the entries where the end time is after the last milestone, if any
    # and less than or equal to this milestone's end time.
    previous_milestone = self.previous_milestone
    start_at = if previous_milestone then previous_milestone.end_at else nil end
    real_entries = LessonPlanEntry.where("end_at <= :end_at " +
      (if previous_milestone then "AND end_at > :start_at" else "" end),
      :end_at => self.end_at, :start_at => start_at)

    virtual_entries = course.lesson_plan_virtual_entries(start_at, self.end_at)
    logger.info virtual_entries
    real_entries + virtual_entries
  end
end
