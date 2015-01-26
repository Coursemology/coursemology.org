class ManualRewardsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data

  def manual_exp
    authorize! :award_points, UserCourse

    if params.has_key?(:all_students)
      @student_courses = @course.student_courses_sorted_by_name
    else
      @student_courses = @course.tutorial_groups.where(tut_course_id:curr_user_course).map {|m| m.std_course}
      if !@student_courses
        @student_courses = @course.student_courses_sorted_by_name
      end
    end

    exps = params[:exps]
    if exps
      count = 0
      exps.each do |std_course_id, exp_str|
        exp = exp_str.to_i
        if exp != 0
          curr_user_course.manual_exp_award(std_course_id,exp,params[:reason])
          count += 1
        end
      end
      flash[:notice] = "EXPs have been awarded to #{count} students!"
    end
  end

  def manual_achievement
    authorize! :award_points, UserCourse
    @achievements = @course.achievements.where(auto_assign: false)

    if params.has_key?(:all_students)
      @student_courses = @course.user_courses.student
    else
      @student_courses = @course.tutorial_groups.where(tut_course_id:curr_user_course).map {|m| m.std_course}
      if !@student_courses
        @student_courses = @course.user_courses.student
      end
    end

    ach_ids = params[:achs]
    std_course_ids = params[:std_courses]

    if ach_ids && std_course_ids
      achs = ach_ids.map{ |id| @course.achievements.find(id) }
      std_courses = std_course_ids.map{ |id| @course.student_courses.find(id) }

      std_courses.each do |std_course|
        achs.each do |ach|
          std_course.give_achievement(ach)
        end
        std_course.update_exp_and_level_async
      end

      flash[:notice] = "#{achs.size} achievements have been awarded to #{std_courses.size} students!"
    end
  end

  def remove_achievement
    authorize! :award_points, UserCourse
    @achievements = @course.achievements.where(auto_assign: false)

    if params.has_key?(:all_students)
      @student_courses = @course.user_courses.student
    else
      @student_courses = @course.tutorial_groups.where(tut_course_id:curr_user_course).map {|m| m.std_course}
      if !@student_courses
        @student_courses = @course.user_courses.student
      end
    end

    ach_ids = params[:achs]
    std_course_ids = params[:std_courses]

    if ach_ids && std_course_ids
      achs = ach_ids.map{ |id| @course.achievements.find(id) }
      std_courses = std_course_ids.map{ |id| @course.student_courses.find(id) }

      std_courses.each do |std_course|
        achs.each do |ach|
          std_course.remove_achievement(ach)
        end
      end

      flash[:notice] = "#{achs.size} achievements have been removed from #{std_courses.size} students!"
    end
  end
end
