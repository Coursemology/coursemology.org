class TrainingsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :training, through: :course, except: [:index]

  def index
    # check if student has a training submission for each training
    @trainings = @course.trainings.opened.order("open_at DESC")
    if current_uc && current_uc.is_lecturer?
      @trainings = @course.trainings.future.order(:open_at) + @trainings
    end
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
