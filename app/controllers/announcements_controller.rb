class AnnouncementsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :announcement, through: :course, except: [:index]

  before_filter :load_general_course_data, only: [:show, :index, :edit, :new]

  def index
    @is_new = {}
    @paging_pref = @course.paging_pref(Announcement.to_s)
    @announcements = @course.announcements.accessible_by(current_ability)
                        .order("publish_at DESC")
    if @paging_pref.display
      @announcements = @announcements.page(params[:page]).per(@paging_pref.prefer_value.to_i)
    end
    if curr_user_course.id
      unseen = @announcements - curr_user_course.seen_announcements
      unseen.each do |ann|
        @is_new[ann.id] = true
        curr_user_course.mark_as_seen(ann)
      end
    end
  end

  def new
    @announcement.publish_at = DateTime.now
    @announcement.expiry_at = 3.days.from_now
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
