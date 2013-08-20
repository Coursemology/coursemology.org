class StudentSummaryController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data

  def index
    authorize! :manage, UserCourse
    case sort_column
      when 'Exp'
        @students = @course.user_courses.student.where(is_phantom: false).order("exp " + sort_direction)
      when 'Level'
        @students = @course.user_courses.student.where(is_phantom: false).order("level_id " + sort_direction)
      when 'Name'
        @students = @course.user_courses.student.where(is_phantom: false).sort_by { |std| std.user.name.downcase }
        @students = sort_direction == 'asc' ? @students : @students.reverse
      else
        @students = @course.user_courses.student.where(is_phantom: false).order("exp desc")
    end

    @std_summary_paging = @course.std_summary_paging_pref
    if @std_summary_paging.display?
      @students = Kaminari.paginate_array(@students).page(params[:page]).per(@std_summary_paging.prefer_value.to_i)
    end
  end
end
