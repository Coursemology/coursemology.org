class StaffLeaderboardController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, only: [:index, :monitoring]

  require 'enumerable'

  def index
    @tab = 'Summary'
    authorize! :view, :staff_leaderboard
    # summaries =[summary[:tutor], summary[:detail], summary[:students]]
    @result = {}
    tutors = get_tutors
    tutors.each do |tutor|
      students = tutor.std_courses.where(is_phantom: false).includes(:user_achievements, :level)

      @result[tutor.id] = {achievements: 0}
      @result[tutor.id][:students] = students
      next if students.length == 0
      ach_count = students.reduce(0){|acc, std| acc + std.user_achievements.length }
      @result[tutor.id][:achievements] = (ach_count / students.length.to_f).round(2)
    end
    tutors = tutors.sort_by {|ta| -@result[ta.id][:achievements] }
    @result[:tutors] = tutors

  end


  def monitoring
    authorize! :view, :staff_leaderboard
    @tab = 'Monitoring'
    if params[:_tutor_id]
      tutor = UserCourse.find(params[:_tutor_id])
      @tutor_details = {}
      @tutor_details[:tutor] = tutor.name
      @tutor_details[:gradings] = tutor.gradings.includes(:submission).order(:created_at)
    end
    @tutors = get_tutors

    @summaries = {}
    @tutors.each do |tutor|
      gradings = tutor.gradings.includes(:submission).order(:created_at)
      summary = { count: gradings.length, avg: Float::INFINITY, std_dev: Float::INFINITY }
      @summaries[tutor.id] = summary
      @summaries[tutor.id][:std_count] = tutor.std_courses.where(is_phantom: false).count
      time_diff = gradings.reduce([]) { |acc, g| (g.created_at - g.submission.submitted_at > 0) ? (acc << g.created_at - g.submission.submitted_at) : acc }
      next if time_diff.empty?
      avg = time_diff.mean
      std_dev = time_diff.standard_deviation
      summary[:count] = gradings.length
      summary[:avg] = avg
      summary[:std_dev] = std_dev
    end
    @tutors = @tutors.sort_by! { |tutor| [@summaries[tutor.id][:avg], @summaries[tutor.id][:std_dev]] }
  end


  private
  #staff with students assigned to them (tutor or lecturer)
  def get_tutors
    staff = @course.user_courses.staff.where(is_phantom: false)
    tutors = []
    staff.each do |tutor|
      students = tutor.std_courses.where(is_phantom: false)
      tutors << tutor if tutor.is_ta? || students.length > 0
    end
    tutors
  end
end
