class TagGroupsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :tag_group, through: :course

  before_filter :load_general_course_data, only: [:new, :edit, :create]

  def new
  end

  def edit
  end

  def create
    expire_fragment("course/#{@course.id}/tags")
    respond_to do |format|
      if @tag_group.save
        format.html { redirect_to course_tags_path(@course),
                      notice: "The tag group '#{@tag_group.name}' has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    expire_fragment("course/#{@course.id}/tags")
    respond_to do |format|
      if @tag_group.update_attributes(params[:tag_group])
        format.html { redirect_to course_tags_path(@course),
                      notice: "The tag group '#{@tag_group.name}' has been updated." }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    expire_fragment("course/#{@course.id}/tags")
    @tag_group.destroy
    respond_to do |format|
      format.html { redirect_to course_tags_url(@course),
                    notice: "The tag group '#{@tag_group.name}' has been removed." }
    end
  end
end
