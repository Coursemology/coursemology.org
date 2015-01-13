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

    if params[:assessment_training][:dependent_on_attributes]
      @training.dependent_on_ids = params[:assessment_training][:dependent_on_attributes].values.select {|t| t[:_destroy] == "false"}.collect {|t| t[:dependent_on_ids]}
    end
    params[:assessment_training].delete(:dependent_on_attributes)

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

    if params[:assessment_training][:dependent_on_attributes]
      params[:assessment_training][:dependent_on_ids] = params[:assessment_training][:dependent_on_attributes].values.select {|t| t[:_destroy] == "false"}.collect {|t| t[:dependent_on_ids]}
    end
    params[:assessment_training].delete(:dependent_on_attributes)

    respond_to do |format|
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
    asm_qn = Assessment::Question.where(as_question_type:params[:qtype].gsub('__', '::'), as_question_id: params[:qid]).first
    to_asm = Assessment::Training.find(params[:to])

    clone = asm_qn.dup
    qa = to_asm.assessment.question_assessments.new
    qa.question = clone
    qa.position = to_asm.questions.count

    clone.save
    qa.save

    if params[:move] == 'true'
      asm_qn.destroy
    end

    render nothing: true
  end
end
