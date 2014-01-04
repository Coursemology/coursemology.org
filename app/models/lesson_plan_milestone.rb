class LessonPlanMilestone < ActiveRecord::Base
  attr_accessible :title, :description, :end_at, :start_at

  belongs_to :course
  belongs_to :creator, class_name: "User"

  validates :start_at, presence: true, allow_blank: false

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
    self.course.lesson_plan_milestones.where("start_at < :start_at", :start_at => self.start_at).order("start_at ASC").first
  end

  def next_milestone
    self.course.lesson_plan_milestones.where("start_at > :start_at", :start_at => self.start_at).order("start_at DESC").first
  end

  def entries(include_virtual = true)
    next_milestone = self.next_milestone
    cutoff_time = if next_milestone and !next_milestone.is_virtual? then next_milestone.start_at else self.end_at end

    start_after_us = "start_at >= :start_at"
    before_cutoff = " AND start_at < :cutoff"
    in_current_course = " AND course_id = :course_id"

    actual_entries = LessonPlanEntry.where(start_after_us + before_cutoff + in_current_course,
      :start_at => self.start_at, :cutoff => cutoff_time, :course_id => self.course_id)

    if include_virtual
      virtual_entries = course.lesson_plan_virtual_entries(self.start_at, cutoff_time)
      actual_entries + virtual_entries
    else
      actual_entries
    end
  end

  def is_virtual?
    false
  end
end
