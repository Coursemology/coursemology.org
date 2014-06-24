class Assessment::TrainingsController < Assessment::AssessmentsController
  load_and_authorize_resource :course
  load_and_authorize_resource :training, class: "Assessment::Training", through: :course

  before_filter :load_general_course_data, only: [:show, :index, :edit, :new, :access_denied, :stats, :overview]

  def index
    @is_new = {}
    @tags_map = {}
    @selected_tags = params[:tags]
    @display_columns = {}
    @course.training_columns_display.each do |cp|
      @display_columns[cp.preferable_item.name] = cp.prefer_value
    end
    @time_format =  @course.training_time_format
    @reattempt = @course.course_preferences.training_reattempt.first

    @trainings = @course.trainings.accessible_by(current_ability)
    @paging = @course.trainings_paging_pref

    if @selected_tags
      tags = Tag.find(@selected_tags)
      training_ids = tags.map{ |tag| tag.trainings.map { |t| t.id } }.reduce(:&)
      @trainings = @trainings.where(id: training_ids)

      tags.each { |tag| @tags_map[tag.id] = true }
    end

    @tabs = @course.training_tabs
    @tab_id = params['_tab']

    if params['_tab'] and (@tab = @course.tabs.where(id:@tab_id).first)
      @trainings = @tab.trainings
    elsif @tabs.length > 0
      @tab_id = @tabs.first.id.to_s
      @trainings = @tabs.first.trainings
    else
      @tab_id='Trainings'
    end

    @trainings = @trainings.accessible_by(current_ability)

    if @paging.display?
      @trainings = @trainings.page(params[:page]).per(@paging.prefer_value.to_i)
    end

    if curr_user_course.id
      unseen = @trainings - curr_user_course.seen_trainings
      unseen.each do |tn|
        @is_new[tn.id] = true
        curr_user_course.mark_as_seen(tn)
      end
    end

    @trainings_with_sbm = []
    @trainings.each do |training|
      if curr_user_course.id
        std_sbm = TrainingSubmission.where(
            std_course_id: curr_user_course.id,
            training_id: training.id
        ).last
      end
      @trainings_with_sbm << {
          training: training,
          submission: std_sbm
      }
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
    authorize! :manage, :bulk_update
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
    authorize! :manage, :bulk_update
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
