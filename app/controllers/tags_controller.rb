class TagsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :tag, through: :course

  before_filter :load_general_course_data, only: [:new, :edit, :show, :index]

  def new
    @tag_groups = @course.tag_groups
  end

  def create
    respond_to do |format|
      if @tag.save
        format.html { redirect_to course_tags_path(@course),
                      notice: "The tag '#{@tag.name}' has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
    @tag_groups = @course.tag_groups
  end

  def update
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        format.html { redirect_to course_tags_path(@course),
                      notice: "The tag '#{@tag.name}' has been updated." }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def show
    @missions = @tag.missions.accessible_by(current_ability)
    @trainings = @tag.trainings.accessible_by(current_ability)
  end

  def index
    @tag_groups = @course.tag_groups
    @uncat_tags = @course.tags.uncategorized
  end

  def destroy
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to course_tags_url(@course),
                    notice: "The tag '#{@tag.name}' has been removed." }
    end

  end
end
