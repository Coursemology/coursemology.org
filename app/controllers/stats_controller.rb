class StatsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data

  def general
  end

  # data is a map of the chart column to list of student submission
  def produce_submission_graph(data, key_label, graph_title)
    grade_table = GoogleVisualr::DataTable.new
    grade_table.new_column('string', key_label)
    grade_table.new_column('number', 'Count')
    grade_table.new_column('string', nil, nil, 'tooltip')
    data.sort.each do |k, sbms|
      row = []
      row << k.to_s
      row << sbms.size
      tooltip = sbms.map { |sbm| sbm.std_course.name }.join(", ")
      row << tooltip
      grade_table.add_row(row)
    end
    opts   = { width: 600, height: 240, title: graph_title, hAxis: { title: key_label } }
     GoogleVisualr::Interactive::ColumnChart.new(grade_table, opts)
  end

  def mission
    @mission = Assessment::Mission.find(params[:mission_id])
    authorize! :view_stat, @mission

    @sbms = @mission.sbms
    @graded = @sbms.where(status: 'graded').map { |sbm| sbm.std_course }
    @submitted = @sbms.where(status: 'submitted').map { |sbm| sbm.std_course }
    @attempting = @sbms.where(status: 'attempting').map { |sbm| sbm.std_course }

    # TODO: split submitted to doing vs submitted
    # when saving mission is allowed

    all_std = @course.student_courses
    @unsubmitted = all_std -  @attempting -  @submitted - @graded

    sbms_graded = @sbms.graded
    sbms_by_grade = sbms_graded.group_by { |sbm| sbm.get_final_grading.grade }
    @grade_chart = produce_submission_graph(sbms_by_grade, 'Grade', 'Grade distribution')

    sbms_by_date = sbms_graded.group_by { |sbm| sbm.created_at.to_date.to_s }
    @date_chart = produce_submission_graph(sbms_by_date, 'Date', 'Start date distribution')

    @missions = @course.missions
    @trainings = @course.trainings
  end

  def training
    @training = Training.find(params[:training_id])
    authorize! :view_stat, @training

    @summary = {}
    is_all = ((params[:mode] != nil) && params[:mode] == "all") || (curr_user_course.std_courses.count == 0)
    puts is_all

    #TODO: may want to deal with phantom students here
    @summary[:all] = is_all
    std_courses = is_all ? @course.student_courses : curr_user_course.std_courses
    @summary[:student_courses] = std_courses

    submissions =  @training.sbms.where(std_course_id: std_courses)
    submitted = submissions.map { |sbm| sbm.std_course }

    @not_started = std_courses - submitted
    @summary[:not_started] = @not_started

    sbms_by_grade = submissions.group_by { |sbm| sbm.get_final_grading.grade }
    @summary[:grade_chart] = produce_submission_graph(sbms_by_grade, 'Grade', 'Grade distribution')

    sbms_by_date = submissions.group_by { |sbm| sbm.created_at.strftime("%m-%d") }
    @summary[:date_chart] = produce_submission_graph(sbms_by_date, 'Date', 'Start date distribution')

    if @training.can_skip?
      @summary[:progress] = submissions.group_by{ |sbm| sbm.answered_questions.size + 1 }
    else
      @summary[:progress] = submissions.group_by(&:current_step).sort.reverse
    end

    @summary[:progress_chart] = produce_submission_graph(@summary[:progress], 'Step', 'Current step of students')

    #@mcqs = @training.mcqs
    #@coding_question = @training.coding_questions

    @missions = @course.missions
    @trainings = @course.trainings
  end
end
