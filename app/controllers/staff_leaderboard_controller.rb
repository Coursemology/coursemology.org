class StaffLeaderboardController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, only: [:index, :monitoring]

  require 'enumerable'

  def index
    authorize! :can, :view, :staff_leaderboard
    # summaries =[summary[:tutor], summary[:detail], summary[:students]]
    @summaries = {}
    @tutors = tutors
    @tutors.each do |tutor|
      students = tutor.get_only_tut_stds.select {|std| !std.is_phantom?}
      @summaries[tutor.id]= {achievements: 0}
      next if students.count == 0
      ach_count = students.reduce(0){|acc, std| acc + std.user_achievements.count }
      @summaries[tutor.id][:achievements] = (ach_count / students.count.to_f).round(2)
    end
    @tutors = @tutors.sort_by {|ta| -@summaries[ta.id][:achievements] }
  end


  def monitoring
    if params[:_tutor_id]
      tutor = UserCourse.find(params[:_tutor_id])
      @tutor_details = {}
      @tutor_details[:tutor] = tutor.name
      @tutor_details[:gradings] = tutor.submission_gradings
    end
    @tutors = tutors

    @summaries = {}
    @tutors.each do |tutor|
      summary = {count: 0, avg: nil, std_dev: nil }
      @summaries[tutor.id] = summary
      gradings = tutor.submission_gradings.order(:created_at)
      if gradings.count == 0
        next
      end
      time_diff = gradings.reduce([]) { |acc, g| (g.created_at - g.sbm.submit_at > 0) ? (acc << g.created_at - g.sbm.submit_at) : acc }
      avg = time_diff.mean
      std_dev = time_diff.standard_deviation
      summary[:count] = gradings.count
      summary[:avg] = avg
      summary[:std_dev] = std_dev
    end
  end


  private
  #staff with students assigned to them (tutor or lecturer)
  def tutors
    staff = @course.user_courses.staff.where(is_phantom: false)
    tutors = []
    staff.each do |tutor|
      students = tutor.get_only_tut_stds.select {|std| !std.is_phantom?}
      tutors << tutor if tutor.is_ta? || students.count > 0
    end
    tutors
  end
end
