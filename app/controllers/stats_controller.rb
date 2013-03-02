class StatsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data

  def general
    @missions = @course.missions
    @trainings = @course.trainings
    @levels = @course.levels
    @achievements = @course.achievements
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
      tooltip = sbms.map { |sbm| sbm.std_course.user.name }.join(", ")
      row << tooltip
      grade_table.add_row(row)
    end
    opts   = { width: 600, height: 240, title: graph_title, hAxis: { title: key_label } }
    chart = GoogleVisualr::Interactive::ColumnChart.new(grade_table, opts)
    return chart
  end

  def mission
    @mission = Mission.find(params[:mission_id])
    authorize! :view_stat, @mission

    @sbms = @mission.sbms
    @submitted = @sbms.map { |sbm| sbm.std_course }
    # TODO: split submitted to doing vs submitted
    # when saving mission is allowed

    all_std = @course.student_courses
    @unsubmitted = all_std - @submitted

    sbms_graded = @sbms.graded
    sbms_by_grade = sbms_graded.group_by { |sbm| sbm.get_final_grading.total_grade }
    @grade_chart = produce_submission_graph(sbms_by_grade, 'Grade', 'Grade distribution')

    sbms_by_date = sbms_graded.group_by { |sbm| sbm.created_at.to_date.to_s }
    @date_chart = produce_submission_graph(sbms_by_date, 'Date', 'Start date distribution')

    @missions = @course.missions
    @trainings = @course.trainings
  end

  def training
    @training = Training.find(params[:training_id])
    authorize! :view_stat, @training

    @sbms = @training.sbms
    @submitted = @sbms.map { |sbm| sbm.std_course }
    # TODO: split submitted to doing vs submitted
    # when saving mission is allowed

    all_std = @course.student_courses
    @unsubmitted = all_std - @submitted

    sbms_graded = @sbms
    sbms_by_grade = sbms_graded.group_by { |sbm| sbm.get_final_grading.total_grade }
    @grade_chart = produce_submission_graph(sbms_by_grade, 'Grade', 'Grade distribution')

    sbms_by_date = sbms_graded.group_by { |sbm| sbm.created_at.to_date.to_s }
    @date_chart = produce_submission_graph(sbms_by_date, 'Date', 'Start date distribution')

    @mcqs = @training.mcqs

    @missions = @course.missions
    @trainings = @course.trainings
  end
end
