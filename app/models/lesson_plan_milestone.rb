class LessonPlanMilestone < ActiveRecord::Base
  attr_accessible :title, :description, :end_at, :start_at

  belongs_to :course
  belongs_to :creator, class_name: "User"

  validates :end_at, presence: true, allow_blank: false

  # Creates a virtual item of this class that is backed by some other data store.
  def self.create_virtual(*args)
    (Class.new do
        def initialize(other_entries)
          @previous_milestone = nil
          @next_milestone = nil
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
        def start_at
          nil
        end
        def end_at
          nil
        end
        def previous_milestone
          @previous_milestone
        end
        def previous_milestone=(milestone)
          @previous_milestone = milestone
        end
        def next_milestone
          @next_milestone
        end
        def next_milestone=(milestone)
          @next_milestone = milestone
        end
        def is_virtual?
          true
        end
    end).new(*args)
  end
  
  def previous_milestone
    self.course.lesson_plan_milestones.where("end_at < :end_at", :end_at => self.end_at).order("end_at DESC").first
  end

  def next_milestone
    self.course.lesson_plan_milestones.where("start_at > :start_at", :start_at => self.start_at).order("start_at DESC").first
  end

  def entries(include_virtual = true)
    # Find the entries where the end time is after the last milestone, if any
    # and less than or equal to this milestone's end time.
    previous_milestone = self.previous_milestone
    start_at = if previous_milestone then previous_milestone.end_at else nil end
    real_entries = LessonPlanEntry.where("end_at <= :end_at " +
      (if previous_milestone then "AND end_at > :start_at" else "" end) +
      " AND course_id = :course_id",
      :end_at => self.end_at, :start_at => start_at, :course_id => self.course_id)

    if include_virtual
      virtual_entries = course.lesson_plan_virtual_entries(start_at, self.end_at)
      real_entries + virtual_entries
    else
      real_entries
    end
  end

  def is_virtual?
    false
  end
end
