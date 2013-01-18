class AnnouncementsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :announcement, through: :course, except: [:index]

  before_filter :load_general_course_data, only: [:show, :index, :edit, :new]

  def index
    @is_new = {}
    if curr_user_course.id
      @announcements = curr_user_course.get_announcements
      unseen = curr_user_course.get_unseen_announcements
      unseen.each do |ann|
        @is_new[ann.id] = true
        curr_user_course.mark_as_seen(ann)
      end
    else
      @announcements = @course.announcements.published.order("publish_at DESC")
    end
    @announcements.each do |ann|
      authorize! :index, ann
    end
    respond_to do |format|
      format.html # index.html.erb
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
        format.html { redirect_to course_announcements_url(@course),
                      notice: "The announcement '#{@announcement.title}' has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @announcement.update_attributes(params[:announcement])
        format.html { redirect_to course_announcements_url(@course),
                      notice: "The announcement '#{@announcement.title}' has been updated." }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @announcement.destroy

    respond_to do |format|
      format.html { redirect_to course_announcements_url,
                    notice: "The announcement '#{@announcement.title}' has been removed." }
    end
  end
end
