class ComicsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :comic, through: :course

  before_filter :load_general_course_data, only: [:index, :new, :edit, :show]

  def index
    @comics = @course.comics
    unseen = @comics - curr_user_course.seen_comics

    @is_new = {}
    unseen.each do |comic|
      @is_new[comic.id] = true
    end
  end

  def edit
    @comic_pages = ComicPage.where(comic_id: @comic.id).includes(:file).order('page')
  end

  def new
    last_chapter = Comic.where(course_id: @course).order('chapter DESC').first
    last_episode = Comic.where(course_id: @course).order('chapter DESC, episode DESC').first
    @comic.chapter = last_chapter ? last_chapter.chapter : 1
    @comic.episode = (last_episode ? last_episode.episode : 0) + 1
  end

  def show
    if @comic.can_view?(curr_user_course)
      @comic_pages = ComicPage.where(comic_id: @comic.id).includes(:file).order('page')
      curr_user_course.mark_as_seen(@comic)
    else
      redirect_to course_comics_url
    end
  end

  def info
    if @comic.can_view?(curr_user_course)
      result = {}
      result[:current] = @comic
      result[:pages] = []
      @comic.comic_pages.includes(:file).order('page').each do |page|
        result[:pages] << {url: page.file.file.url,
                           page: page.page,
                           tbc: page.is_tbc}
      end
      if @comic.next_mission && @comic.next_mission.can_start?
        result[:next_mission] = {title: @comic.next_mission.title,
                                 url: course_mission_url(@course, @comic.next_mission)}
      end
      result[:next] = @comic.next_episode(curr_user_course)
      result[:prev] = @comic.prev_episode(curr_user_course)
      curr_user_course.mark_as_seen(@comic)
      render json: result
    else
      redirect_to course_comics_url
    end

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
