class LessonPlanMilestone < ActiveRecord::Base
  attr_accessible :title, :description, :end_at

  belongs_to :course
  belongs_to :creator, class_name: "User"

  # Creates a virtual item of this class that is backed by some other data store.
  def self.create_virtual(*args)
    (Class.new do
        def initialize(other_entries)
          @other_entries = other_entries
        end

        def title
          "Other Items"
        end
        def description
          nil
        end
        def entries
          @other_entries
        end
        def end_at
          nil
        end

        def is_virtual
          true
        end
    end).new(*args)
  end
  
  def previous_milestone
    self.course.lesson_plan_milestones.where("end_at < :end_at", :end_at => self.end_at).order("end_at DESC").first
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
    real_entries + virtual_entries
  end

  def is_virtual
    false
  end
end
