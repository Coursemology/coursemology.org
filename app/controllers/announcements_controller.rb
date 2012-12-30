class AnnouncementsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :announcement, through: :course, except: [:index]

  before_filter :load_sidebar_data, only: [:show, :index, :edit, :new]

  def index
    @is_new = {}
    if current_uc
      @announcements = current_uc.get_announcements
      unseen = current_uc.get_unseen_announcements
      unseen.each do |ann|
        @is_new[ann.id] = true
        current_uc.mark_as_seen(ann)
      end
    else
      @announcements = @course.announcements.published.order("publish_at DESC")
    end
    authorize! :index, @announcements
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @announcement.publish_at = DateTime.now
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
  end

  def create
    @announcement.creator = current_user
    respond_to do |format|
      if @announcement.save
        format.html { redirect_to course_announcement_url(@course, @announcement),
                      notice: 'announcement was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @announcement.update_attributes(params[:announcement])
        format.html { redirect_to course_announcement_url(@course, @announcement),
                      notice: 'announcement was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @announcement.destroy

    respond_to do |format|
      format.html { redirect_to course_announcements_url }
    end
  end
end
