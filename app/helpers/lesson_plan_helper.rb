module LessonPlanHelper
  # Returns a hash of the human-readable type, to the CSS class of the type of entry
  def get_lesson_plan_entry_types
    result = LessonPlanEntry::ENTRY_TYPES.map { |type|
      type[0]
    }
    virtual_entry_types = @course.lesson_plan_virtual_entries.reduce([]) { |rest, e|
      if rest.include?(e.entry_real_type) then
        rest
      else
        rest << e.entry_real_type
      end
    }

    result + virtual_entry_types
  end

  def get_lesson_plan_entry_css_class(type)
    "lesson-plan-type-" + type
  end
end

