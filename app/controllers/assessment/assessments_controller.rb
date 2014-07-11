class Assessment::AssessmentsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assessment, only: [:reorder]
  before_filter :load_general_course_data, only: [:show, :index, :new, :edit, :access_denied, :stats, :overview]

  def index
    assessment_type = params[:type]
    selected_tags = params[:tags]

    display_columns = {}
    time_format =  @course.time_format(assessment_type)
    paging = @course.paging_pref(assessment_type)
    @course.assessment_columns(assessment_type, true).each do |cp|
      display_columns[cp.preferable_item.name] = cp.prefer_value
    end

    @assessments = @course.assessments.send(assessment_type).includes(:as_assessment)

    if selected_tags
      tags = Tag.find(selected_tags)
      @assessments = tags.questions.assessmenets
    end

    #TODO: refactoring
    if assessment_type == 'training'
      @tabs = @course.tabs.training
      @tab_id = params['_tab']

      if params['_tab'] and (@tab = @course.tabs.where(id:@tab_id).first)
        @assessments = @tab.assessments
        #@trainings = @trainings.where(t_type: AssignmentType.extra)
      elsif @tabs.length > 0
        @tab_id = @tabs.first.id.to_s
        @assessments= @tabs.first.assessments
      else
        @tab_id='Trainings'
      end
    end

    if paging.display?
      @assessments = @assessments.accessible_by(current_ability).page(params[:page]).per(paging.prefer_value.to_i)
    end

    submissions = @course.submissions.where(assessment_id: @assessments.map {|m| m.id},
                                             std_course_id: curr_user_course.id)

    sub_ids = submissions.map {|s| s.assessment_id}
    sub_map = {}
    submissions.each do |sub|
      sub_map[sub.assessment_id] = sub
    end

    action_map = {}
    @assessments.each do |ast|
      if sub_ids.include? ast.id
        attempting = sub_map[ast.id].attempting?
        action_map[ast.id] = { action: attempting ? "Edit" : "Review",
                               url: edit_course_assessment_assessment_submission_path(@course, ast, sub_map[ast.id]) }

      #potential bug
      #1, can mange, 2, opened and fulfil the dependency requirements
      elsif (ast.opened? and (ast.as_assessment.class == Assessment::Training or
          ast.dependent_id.nil? or
          (sub_ids.include? ast.dependent_id and sub_map[ast.dependent_id].submitted?))) or
          can?(:manage, ast)

        action_map[ast.id] = {action: "Attempt",
                            url: new_course_assessment_assessment_submission_path(@course, ast)}
      else
        action_map[ast.id] = {action: nil}
      end

      action_map[ast.id][:new] = false
      action_map[ast.id][:opened] = ast.opened?
      action_map[ast.id][:published] = ast.published
      action_map[ast.id][:title_link] =
          can?(:manage, ast) ?
              stats_course_assessment_path(@course, ast) :
              course_assessment_path(@course, ast)
    end

    @summary = {selected_tags: selected_tags,
                actions: action_map,
                columns: display_columns,
                time_format: time_format,
                paging: paging,
                module: assessment_type.humanize
    }

    if curr_user_course.id
      unseen = @assessments - curr_user_course.seen_assessments
      unseen.each do |um|
        action_map[um.id][:new] = true
        curr_user_course.mark_as_seen(um)
      end
    end
  end


  def show
    @assessment_type = extract_type

  end

  def reorder
    @assessment.question_assessments.reordering(params['sortable-item'])
    #TODO; we need to clean up dependency after reordering

    render nothing: true
  end

  private

  def extract_type
    controller = request.filtered_parameters["controller"].split('/').last
    controller.singularize
  end

end