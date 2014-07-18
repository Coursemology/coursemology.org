class Forums::ForumsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, except: [:destroy, :mark_read, :mark_all_read, :next_unread, :next_unanswered, :subscribe, :unsubscribe, :toggle_lock]

  before_filter :load_forum, except: [:index, :mark_all_read, :next_unread, :next_unanswered]
  load_and_authorize_resource :forum, except: [:index, :mark_all_read, :next_unread, :next_unanswered]

  def index
    @forums = @course.forums.accessible_by(current_ability)
  end

  def show
    @topics = @forum.topics.accessible_by(current_ability).order('created_at DESC')
    @topics = @topics.page(params[:page]).per(@course.paging_pref('Forum').prefer_value.to_i)
  end

  def new

  end

  def create
    @forum.assign_attributes(params[:forum_forum])
    @forum.course = @course
    @forum.save

    respond_to do |format|
      format.html { redirect_to course_forum_path(@course, @forum),
                                notice: 'The forum was successfully created.' }
    end
  end

  def edit

  end

  def update
    @forum.assign_attributes(params[:forum_forum])

    respond_to do |format|
      format.html do
        if @forum.save
          redirect_to course_forum_path(@course, @forum),
                      notice: 'The forum was successfully updated.'
        else
          render action: 'edit'
        end
      end
    end
  end

  def destroy
    @forum.destroy

    respond_to do |format|
      format.html { redirect_to course_forums_path(@course),
                                notice: 'The forum was successfully deleted.' }
    end
  end

  def subscribe
    subscription = ForumForumSubscription.create
    subscription.forum = @forum
    subscription.user = curr_user_course

    respond_to do |format|
      if subscription.save
        format.html { redirect_to course_forum_path(@course, @forum),
                                  notice: 'You have subscribed to the forum.' }
        format.json { render json: {status: 'OK'}}
      end
    end
  end

  def unsubscribe
    ForumForumSubscription.delete_all(forum_id: @forum, user_id: curr_user_course)

    respond_to do |format|
      format.html { redirect_to course_forum_path(@course, @forum),
                                notice: 'You have been unsubscribed from the forum.' }
      format.json { render json: {status: 'OK'}}
    end
  end

  def mark_read
    curr_user_course.mark_as_seen(@forum.unread_topics(curr_user_course).all)

    respond_to do |format|
      format.html { redirect_to course_forum_path(@course, @forum) }
    end
  end

  def mark_all_read
    @course.forums.accessible_by(current_ability).each do |f|
      curr_user_course.mark_as_seen(f.unread_topics(curr_user_course).all)
    end

    respond_to do |format|
      format.html { redirect_to course_forums_path(@course) }
    end
  end

  def next_unread
    @course.forums.accessible_by(current_ability).each do |f|
      topics = f.unread_topics(curr_user_course)
      if not topics.empty?
        respond_to do |format|
          redirect_to course_forum_topic_path(@course, f, topics.first) and return
        end
      end
    end

    # All read already
    redirect_to course_forums_path(@course),
                notice: 'Hooray! All topics have been read'
  end

  def next_unanswered
    @course.forums.accessible_by(current_ability).each do |f|
      topics = f.unanswered_questions
      if not topics.empty?
        respond_to do |format|
          redirect_to course_forum_topic_path(@course, f, topics.first) and return
        end
      end
    end

    # All answered already
    redirect_to course_forums_path(@course),
                notice: 'Hooray! All topics have been answered'
  end

  def toggle_lock
    @forum.locked = !@forum.locked
    @forum.save

    respond_to do |format|
      format.html { redirect_to course_forum_path(@course, @forum),
                                notice: "Forum: '#{@forum.title}' has been #{@forum.locked? ? 'locked' : 'unlocked'}."}
      format.json { render json: {status: 'OK'}}
    end
  end

  private
  def load_forum
    @forum = ForumForum.find_using_slug(params[:id] || params[:forum_id])
    if %w(new create).include?(params[:action])
      @forum = ForumForum.new
      @forum.assign_attributes(params[:forum])
    end

    raise ActiveRecord::RecordNotFound unless @forum
  end
end
