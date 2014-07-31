class TagsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :tag, through: :course

  before_filter :load_general_course_data, only: [:new, :edit, :create, :show, :index]

  def new
  end

  def create
    expire_fragment("course/#{@course.id}/tags")
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
    expire_fragment("course/#{@course.id}/tags")
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
    @questions =  @course.questions.tagged_with(@tag, any: true)
    @missions = @questions.assessments.accessible_by(current_ability).mission
    @trainings = @questions.assessments.accessible_by(current_ability).training
  end

  def index
    @tag_groups = @course.tag_groups.includes(:tags)
    #always put uncategorized last
    uc = @course.tag_groups.uncategorized
    @tag_groups -= [uc]
    @tag_groups << uc

    respond_to do |format|
      format.json { render json: @tags.map {|t| {id: t.id, name: t.name }}}
      format.html
    end
  end

  def destroy
    expire_fragment("course/#{@course.id}/tags")
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to course_tags_url(@course),
                    notice: "The tag '#{@tag.name}' has been removed." }
    end
  end
end
