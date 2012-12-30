class TrainingsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :training, through: :course, except: [:index]

  before_filter :load_sidebar_data, only: [:show, :index, :edit, :new]

  def index
    @is_new = {}
    if current_uc
      @trainings = current_uc.get_trainings
      unseen = current_uc.get_unseen_trainings
      unseen.each do |tn|
        @is_new[tn.id] = true
        current_uc.mark_as_seen(tn)
      end
    else
      @trainings = @course.trainings.opened.order("open_at DESC")
    end
    puts @is_new
    @trainings_with_sbm = []
    @trainings.each do |training|
      if current_user
        std_sbm = TrainingSubmission.find_by_student_id_and_training_id(
          current_user.id,
          training.id
        )
      end
      @trainings_with_sbm << {
        training: training,
        submission: std_sbm
      }
    end
  end

  def show
    @mcqs = @training.mcqs
  end

  def new
  end

  def create
    @training.pos = @course.trainings.size - 1
    @training.creator = current_user
    respond_to do |format|
      if @training.save
        format.html { redirect_to course_training_url(@course, @training),
                      notice: 'Training was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @training.update_attributes(params[:training])
        format.html { redirect_to course_training_url(@course, @training),
                      notice: 'Training was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @training.errors, status: :unprocessable_entity }
      end
    end

  end

  def destroy
    @training.destroy

    respond_to do |format|
      format.html { redirect_to course_trainings_url }
    end
  end
end
