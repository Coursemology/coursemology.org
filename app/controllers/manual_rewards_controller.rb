class ManualRewardsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data

  def manual_exp
    @student_courses = @course.user_courses.student
    exps = params[:exps]
    if exps
      count = 0
      exps.each do |std_course_id, exp_str|
        exp = exp_str.to_i
        if exp > 0
          std_course = @course.user_courses.find(std_course_id)
          puts std_course, exp
          exp_transaction = ExpTransaction.new
          exp_transaction.exp = exp
          exp_transaction.giver = current_user
          exp_transaction.user_course = std_course
          exp_transaction.reason = params[:reason]
          exp_transaction.is_valid = true
          exp_transaction.save
          std_course.update_exp_and_level
          count += 1
        end
      end
      flash[:notice] = "EXPs have been awarded to #{count} students!"
    end
  end

  def manual_achievement
    @achievements = @course.achievements
    @student_courses = @course.user_courses.student

    ach_ids = params[:achs]
    std_course_ids = params[:std_courses]

    if ach_ids && std_course_ids
      achs = ach_ids.map{ |id| @course.achievements.find(id) }
      std_courses = std_course_ids.map{ |id| @course.student_courses.find(id) }

      std_courses.each do |std_course|
        achs.each do |ach|
          std_course.give_achievement(ach)
        end
        std_course.update_achievements
      end

      flash[:notice] = "#{achs.size} achievements have been awarded to #{std_courses.size} students!"
    end
  end
end
