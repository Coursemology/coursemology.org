class TagsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :tag, through: :course

  before_filter :load_general_course_data, only: [:new, :edit, :show, :index]

  def new
  end

  def create
    respond_to do |format|
      if @tag.save
        format.html { redirect_to course_tag_path(@course, @tag),
                      notice: "Course was successfully created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def show
    puts @tag.asm_tags.to_json
    puts @tag.trainings.to_json, @tag.trainings.count
    if curr_user_course.is_lecturer?
      @trainings = @tag.trainings
    else
      @trainings = @tag.trainings.opened
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        format.html { redirect_to course_tag_path(@course, @tag),
                      notice: 'Tag was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def index
  end
end
