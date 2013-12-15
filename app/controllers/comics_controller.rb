class ComicsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :comic, through: :course, except: [:index]

  before_filter :load_general_course_data, only: [:index, :new, :edit, :show]


  def index
    @comics = @course.comics
  end

  def edit
    @comic_pages = ComicPage.where(comic_id: @comic.id).includes(:file).order('page')
  end

  def new
    last_chapter = Comic.where(course_id: @course).order('chapter DESC').first.chapter
    last_episode = Comic.where(course_id: @course).order('chapter DESC, episode DESC').first.episode
    @comic.chapter = last_chapter || 1
    @comic.episode = (last_episode || 0) + 1
  end

  def show
    @comic_pages = ComicPage.where(comic_id: @comic.id).includes(:file).order('page')
  end

  def create_page
    notice = nil
    if params[:type] == "files" && params[:files] then
      @comic.attach_files(params[:files])
    end

    if @comic.save
      notice = "The files were successfully uploaded."
    else
      notice = "There was an error while uploading files."
    end

    respond_to do |format|
      format.html { redirect_to edit_course_comic_url(@course, @comic),
                                notice: notice }
    end
  end

  def create
    respond_to do |format|
      if @comic.save

        format.html { redirect_to edit_course_comic_url(@course, @comic),
                                  notice: "The comic entry '#{@comic.name}' has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    respond_to do |format|
      notice = nil
      if @comic.update_attributes(params[:comic].except(:comic_page))
        notice = "The comic entry '#{@comic.name}' has been updated."
      end

      if comic_pages = params[:comic][:comic_page]
        comic_pages.each do |id, data|
          comic_page = ComicPage.find_by_id(id)
          comic_page.update_attributes(data)
        end
      end


      if !notice.nil?
        format.html { redirect_to edit_course_comic_url(@course, @comic),
                                  notice: notice }
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
