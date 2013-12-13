class ComicsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :comic, through: :course, except: [:index]

  before_filter :load_general_course_data, only: [:index, :new, :edit]


  def index
    @comics = @course.comics
  end

  def edit

  end

  def new
    last_chapter = Comic.where(course_id: @course).order('chapter DESC').first.chapter
    last_episode = Comic.where(course_id: @course).order('chapter DESC, episode DESC').first.episode
    @comic.chapter = last_chapter || 1
    @comic.episode = (last_episode || 0) + 1
  end

  def create
    respond_to do |format|
      if @comic.save

        format.html { redirect_to course_comics_url(@course),
                                  notice: "The comic entry '#{@comic.name}' has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @comic.update_attributes(params[:comic])

        format.html { redirect_to course_comics_url(@course),
                                  notice: "The comic entry '#{@comic.name}' has been updated." }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @comic.destroy

    respond_to do |format|
      format.html { redirect_to course_comics_url(@course),
                                notice: "The comic entry '#{@comic.name}' has been removed." }
    end
  end


end
