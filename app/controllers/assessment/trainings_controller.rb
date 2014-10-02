class Assessment::TrainingsController < Assessment::AssessmentsController
  load_and_authorize_resource :training, class: "Assessment::Training", through: :course


  def show
    if curr_user_course.is_student? && !current_user.is_admin?
      redirect_to course_assessment_trainings_path
      return
    end
    @assessment = @training.assessment
    super

    @summary[:allowed_questions] = [Assessment::McqQuestion, Assessment::CodingQuestion]
    @summary[:type] = 'training'
    @summary[:specific] = @training

    respond_to do |format|
      format.html { render "assessment/assessments/show" }
    end
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
    if params[:files]
      @training.attach_files(params[:files].values)
    end

    if params[:dependent_on]
      @mission.dependent_on = []
      params[:dependent_on].each do |dep|
        @mission.dependent_on << Assessment.find(dep[:dependent_id])
      end
    end

    respond_to do |format|
      if @training.save
        @training.create_local_file
        format.html { redirect_to course_assessment_training_path(@course, @training),
                                  notice: "The training '#{@training.title}' has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
    @tags = @course.tags
  end

  def update
    respond_to do |format|

      # Have to add the HABTM relationship for new dependencies before updating attributes
      # Bug: Used cocoon for dynamic forms - but it has some issue saving the id of new dependencies
      # fix - dep_on_asm_ids will store dependent assessment ids, and if the id is new, record will be added first
      dep_on_asm_ids = params[:dependent_on].collect { |dep| dep[:dependent_id]}
      params[:assessment_training][:dependent_on_attributes].each do |k, v|
        if v[:id]
          dep_on_asm_ids.delete(v[:id])
        else
          v[:id] = dep_on_asm_ids.pop
          @training.dependent_on << Assessment.find(v[:id])
        end
      end

      if @training.update_attributes(params[:assessment_training])
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
    super
    @tabs = @course.training_tabs
    @tab_id = 'overview'
  end

  def bulk_update
    super
    redirect_to overview_course_assessment_trainings_path
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
end
