class Assessment::TrainingsController < Assessment::AssessmentsController
  load_and_authorize_resource :training, class: "Assessment::Training", through: :course


  def index
    super
    respond_to do |format|
      format.html {render "assessment/index"}
    end
  end

  def show
    if curr_user_course.is_student?
      redirect_to course_assessment_trainings_path
      return
    end

    @steps = @training.questions
  end

  def new
    tab_id = params[:tab]
    if Tab.find_by_id(tab_id)
      @training.tab_id = tab_id
    end
    @training.exp = 200
    @training.open_at = DateTime.now.beginning_of_day
    @training.bonus_exp = 0
    @training.bonus_cutoff_at = DateTime.now.beginning_of_day + 1
    @tags = @course.tags
    @asm_tags = {}
  end

  def create
    @training.position = @course.trainings.count + 1
    @training.creator = current_user
    @training.course_id = @course.id
    @training.update_tags(params[:tags])
    if params[:files]
      @training.attach_files(params[:files].values)
    end

    respond_to do |format|
      if @training.save
        @training.create_local_file
        @training.schedule_tasks(course_assessment_training_url(@course, @training))
        format.html { redirect_to course_assessment_training_path(@course, @training),
                                  notice: "The training '#{@training.title}' has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
    @tags = @course.tags
    @asm_tags = {}
    # @training.asm_tags.each { |asm_tag| @asm_tags[asm_tag.tag_id] = true }
  end

  def update
    @training.update_tags(params[:tags])
    respond_to do |format|
      if @training.update_attributes(params[:assessment_training])
        @training.schedule_tasks(course_assessment_training_url(@course, @training))
        format.html { redirect_to course_assessment_training_url(@course, @training),
                                  notice: "The training '#{@training.title}' has been updated." }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @training.destroy

    respond_to do |format|
      format.html { redirect_to course_assessment_trainings_url,
                                notice: "The training '#{@training.title}' has been removed." }
    end
  end

  def stats
    @submissions = @training.training_submissions
    @std_courses = @course.user_courses.student.order(:name).where(is_phantom: false).order('lower(name)')
    @my_std_courses = curr_user_course.std_courses.order(:name)
  end

  def overview
    authorize! :bulk_update, Assessment
    @tabs = @course.training_tabs
    @tab_id = 'overview'
    @trainings = @course.trainings
    # @trainings = @course.trainings.order(:tab_id, :open_at)
    @display_columns = {}
    @course.training_columns_display.each do |cp|
      @display_columns[cp.preferable_item.name] = cp.prefer_value
    end
  end

  def bulk_update
    authorize! :bulk_update, Assessment
    trainings = params[:trainings]
    success = 0
    fail = 0
    trainings.each do |key, val|
      training = @course.trainings.find(key)
      training.assign_attributes(val)
      unless training.changed?
        next
      end
      if training.save
        success += 1
      else
        fail += 1
      end
    end
    flash[:notice] = "#{success} training(s) updated successfully."
    if fail > 0
      flash[:error] = "#{fail} training(s) failed to update."
    end
    redirect_to course_assessment_trainings_overview_path
  end

  def duplicate_qn
    asm_qn = AsmQn.where(qn_type:params[:qtype], qn_id: params[:qid]).first
    to_asm = Training.find(params[:to])
    is_move = params[:move] == 'true'

    clone = Duplication.duplicate_qn_no_log(asm_qn.qn)
    new_link = asm_qn.dup
    new_link.qn = clone
    new_link.asm = to_asm
    new_link.pos = to_asm.asm_qns.count

    clone.save
    new_link.save
    to_asm.update_grade

    if is_move
      asm = asm_qn.asm
      asm_qn.destroy
      asm.update_grade
      asm.update_qns_pos
    end

    render nothing: true
  end

  def access_denied
  end

end
