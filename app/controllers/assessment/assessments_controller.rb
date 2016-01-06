class Assessment::AssessmentsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assessment, only: [:reorder, :stats, :access_denied]
  before_filter :load_general_course_data, only: [:show, :index, :new, :edit, :access_denied, :stats, :overview, :listall]

  include GradingsSummaryBuilder

  def index
    assessment_type = params[:type]
    selected_tags = params[:tags]

    display_columns = {}
    time_format = @course.time_format(assessment_type)
    paging = @course.paging_pref(assessment_type)
    pdf_export = @course.pdf_export_enabled?(assessment_type)
    @course.assessment_columns(assessment_type, true).each do |cp|
      display_columns[cp.preferable_item.name] = cp.prefer_value
    end

    @assessments = @course.assessments.send(assessment_type)

    if selected_tags
      selected_tags = selected_tags.split(",")
      @assessments = @course.questions.tagged_with(@course.tags.named_any(selected_tags).all, any: true).assessments.send(assessment_type)
    end

    #TODO: refactoring
    if assessment_type == 'training'
      @tabs = @course.tabs.training
      @tab_id = params['_tab']

      if params['_tab'] and (@tab = @course.tabs.where(id:@tab_id).first)
        @assessments = @tab.assessments
      elsif @tabs.length > 0
        @tab_id = @tabs.first.id.to_s
        @assessments= @tabs.first.assessments
      else
        @tab_id='Trainings'
      end
    end
    @assessments = @assessments.includes(:as_assessment)

    if paging.display?
      @assessments = @assessments.accessible_by(current_ability).page(params[:page]).per(paging.prefer_value.to_i)
    else
      @assessments = @assessments.accessible_by(current_ability)
    end

    submissions = @course.submissions.where(std_course_id: curr_user_course.id)

    sub_ids = submissions.map {|s| s.assessment_id}
    sub_map = {}
    submissions.each do |sub|
      sub_map[sub.assessment_id] = sub
    end

    #TODO:bug fix for training action, it's rather complicated
    action_map = {}
    ignore_start_at = @course.ignore_assessment_start_at?

    @assessments.each do |ast|
      if sub_ids.include? ast.id
        attempting = sub_map[ast.id].attempting?
        action_map[ast.id] = { action: attempting ? "Edit" : "Review",
                               url: edit_course_assessment_submission_path(@course, ast, sub_map[ast.id]) }
      else
        # retrieve dependent_submissions
        dep_id = ast.dependent_on_ids
        dep_sub = dep_id.empty? ? [] : dep_id.map { |id| sub_map[id].nil? ? nil : sub_map[id].attempting? }

        #potential bug
        #1, can mange, 2, opened and fulfil the dependency requirements
        if ((ast.opened? || ignore_start_at) && # assessment is open or start at is ignored
              (dep_id.nil? || # i) assessment has no dependent assessments
                ((dep_id - sub_ids).empty? && !(dep_sub.include? true)))) || # ii) dep asm have submissions which are completed
            can?(:manage, ast) # user is admin
          action_map[ast.id] = {action: "Attempt",
                              url: new_course_assessment_submission_path(@course, ast)}
        else
          action_map[ast.id] = {action: nil}
        end
      end

      action_map[ast.id][:new] = false
      action_map[ast.id][:opened] = ast.opened?
      action_map[ast.id][:published] = ast.published
      action_map[ast.id][:title_link] =
          can?(:manage, ast) ?
              stats_course_assessment_path(@course, ast) :
              ast.get_path
    end

    @summary = {selected_tags: selected_tags || [],
                actions: action_map,
                columns: display_columns,
                time_format: time_format,
                paging: paging,
                pdf_export: pdf_export,
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

  # Export all completed assessments of the given type as a zip file of PDFs.
  def dump_pdfs
    assessment_type = params[:type]

    # Abort if PDF export is not enabled.
    unless @course.pdf_export_enabled?(assessment_type)
      redirect_to access_denied_path, alert: "PDF export for #{assessment_type.pluralize} has not been enabled."
      return
    end

    # Configure PDF generation options.
    load_settings_for_printing

    # Create temporary directory to store PDFs.
    Dir.mktmpdir do |dir|

      # For each assessment that has been completed, generate PDF and save to temporary directory. 
      assessments = @course.assessments.send(assessment_type)
      submissions = @course.submissions.where(std_course_id: curr_user_course.id)
      submissions_by_assessment_id = {}
      submissions.each do |s|
        submissions_by_assessment_id[s.assessment_id] = s
      end
      assessments.each do |a|
        @assessment = a
        if submissions_by_assessment_id.has_key?(a.id) 
          @submission = submissions_by_assessment_id[a.id]
          if !@submission.attempting?
            @grading = @submission.get_final_grading
            filename = "#{assessment_type.titleize} #{a.id} - #{a.title}.pdf".gsub(/[^0-9A-Za-z.\-]/, '_')
            case assessment_type
            when 'mission'
              build_gradings_summary true
              pdf_string = render_to_string :pdf => filename, 
                :template => "assessment/gradings/show",
                :formats => [:pdf]
            when 'training'
              @training = @assessment.specific
              pdf_string = render_to_string :pdf => filename, 
                :template => "assessment/training_submissions/show",
                :formats => [:pdf]
            else
              raise "Unknown assessment type - #{assessment_type}"
            end
            File.open(File.join(dir, filename), "wb") do |file|
                file.write pdf_string
            end
          end
        end
      end

      # Zip up PDFs and send zip file to client.
      filename = "PDFs - #{@course.title} - #{assessment_type}.zip".gsub(/[^0-9A-Za-z.\-]/, '_')
      temp_file = Tempfile.new(filename)
      begin
        Zip::ZipOutputStream.open(temp_file) { |zos| }   # Needed to create an empty zip structure.
        Zip::ZipFile.open(temp_file.path, Zip::ZipFile::CREATE) do |zip|
          Dir.foreach(dir) do |file|
            zip.add(file, File.join(dir, file))
          end
        end
        zip_data = File.read(temp_file.path)
        send_data(zip_data, :type => 'application/zip', :filename => filename)
      ensure
        temp_file.close
        temp_file.unlink
      end

    end
  end

  def show
    @summary = {}
    @summary[:questions] = @assessment.questions
    qas = @assessment.question_assessments
    @summary[:qas] = {}
    @summary[:questions].each do |qn|
      @summary[:qas][qn] = qas.where(question_id: qn.id).first
    end
  end

  def stats
    @summary = {}
    @summary[:type] = @assessment.is_mission? ? 'mission' : 'training'
    @stats_paging = @course.paging_pref(@assessment.is_mission? ? "MissionStats" : "TrainingStats")
    @submissions = @assessment.submissions.includes(gradings: :exp_transaction)
    std_courses = @course.user_courses.student.order(:name).where(is_phantom: false).includes(:tut_courses)
    my_std = curr_user_course.std_courses.student.order(:name).where(is_phantom: false).includes(:tut_courses)
    std_phantom = @course.user_courses.student.order(:name).where(is_phantom: true).includes(:tut_courses)

    if @stats_paging.display?
      std_courses = std_courses.page(params[:page]).per(@stats_paging.prefer_value.to_i)
    end


    @summary[:stats] = {'My Students' => my_std, "All Students" => std_courses, "Phantom Students" => std_phantom}
  end

  def reorder
    @assessment.question_assessments.reordering(params['sortable-item'])
    #TODO; we need to clean up dependency after reordering

    render nothing: true
  end

  def overview
    authorize! :bulk_update, Assessment
    @display_columns = {}
    @course.assessment_columns(extract_type, true).each do |cp|
      @display_columns[cp.preferable_item.name] = cp.prefer_value
    end
  end

  def bulk_update
    authorize! :bulk_update, Assessment
    if @course.update_attributes(params[:course])
      flash[:notice] = "Assessment(s) updated successfully."
    else
      flash[:error] = "Assessment(s) failed to update. You may have put an open time that is after #{extract_type == 'missions' ? 'end time' : 'bonus cutoff time'}"
    end
  end

  def listall
    assessment_type = params[:type]

    @summary = {type: assessment_type}
    @summary[:selected_asm] = @course.assessments.find(params[:asm]) if params[:asm] && params[:asm] != "0"
    @summary[:selected_std] = @course.user_courses.find(params[:student]) if params[:student] && params[:student] != "0"
    @summary[:selected_staff] = @course.user_courses.find(params[:tutor]) if params[:tutor] && params[:tutor] != "0"


    assessments = @course.assessments.send(assessment_type)
    @summary[:stds] = @course.student_courses.order(:name)
    @summary[:staff] = @course.user_courses.staff

    sbms = @summary[:selected_asm] ? @summary[:selected_asm].submissions : assessments.submissions
    sbms = sbms.accessible_by(current_ability).where('status != ?','attempting').order(:submitted_at).reverse_order

    if @summary[:selected_std]
      sbms = sbms.where(std_course_id: @summary[:selected_std])
    elsif @summary[:selected_staff]
      sbms = sbms.where(std_course_id: @summary[:selected_staff].get_my_stds)
    end

    if curr_user_course.is_student?
      sbms = sbms.joins(:assessment).where("assessments.published =  1")
    end

    #@unseen = []
    #if curr_user_course.id
    #  @unseen = sbms - curr_user_course.get_seen_sbms
    #  @unseen.each do |sbm|
    #    curr_user_course.mark_as_seen(sbm)
    #  end
    #end

    sbms_paging = nil
    if assessment_type == "training"
      sbms_paging = @course.paging_pref('TrainingSubmissions')
    else
      sbms_paging= @course.paging_pref('MissionSubmissions')
    end

    if sbms_paging.display?
      sbms = sbms.page(params[:page]).per(sbms_paging.prefer_value.to_i)
    end

    @summary[:asms] = assessments
    @summary[:sbms] = sbms
    @summary[:paging] = sbms_paging
  end

  def access_denied
  end

  private

  def extract_type
    controller = request.filtered_parameters["controller"].split('/').last
    controller.singularize
  end
end
