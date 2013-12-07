class Forums::TopicsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, except: [:destroy]

  before_filter :load_forum
  load_and_authorize_resource :forum
  before_filter :load_topic
  load_and_authorize_resource :topic, class: ForumTopic

  def show
    respond_to do |format|
      format.html { render action: 'show' }
    end

    curr_user_course.mark_as_seen(@topic)
    curr_user_course.mark_as_seen(@topic.posts)
  end

  def new

  end

  def create
    ForumTopic.transaction do
      post = ForumPost.new
      post.assign_attributes(params[:forum_topic][:posts])
      post.author = curr_user_course

      params[:forum_topic].delete(:posts)
      @topic.assign_attributes(params[:forum_topic])
      @topic.title = post.title
      @topic.author = curr_user_course
      @topic.forum = @forum

      @topic.save
      post.topic = @topic
      post.save
    end

    respond_to do |format|
      format.html { redirect_to course_forum_topic_path(@course, @forum, @topic),
                                notice: 'The topic was successfully created.' }
    end
  end

  def edit

  end

  def update
    params[:forum_topic][:forum] = @course.forums.where(id: params[:forum_topic][:forum].to_i).first!
    @topic.assign_attributes(params[:forum_topic])

    respond_to do |format|
      if @topic.save
        format.html { redirect_to course_forum_topic_path(@course, @topic.forum, @topic),
                                  notice: 'The topic was successfully updated.' }
      end
    end
  end

  def set_type
    authorize! :edit, @topic
    @topic.topic_type = params[:type]
    respond_to do |format|
      if @topic.save then
        format.html { redirect_to course_forum_topic_path(@course, @forum, @topic),
                                  notice: 'The topic type was successfully updated.' }
        format.json { { status: 'OK' } }
      else
        format.html { redirect_to course_forum_topic_path(@course, @forum, @topic),
                                  flash: { error: 'The topic type could not be updated.' } }
        format.json { { status: 'Error' } }
      end
    end
  end

  def set_lock
    authorize! :edit, @topic
    @topic.locked = params[:lock]

    respond_to do |format|
      if @topic.save then
        format.html { redirect_to course_forum_topic_path(@course, @forum, @topic),
                                  notice: "The topic was was successfully #{params[:lock] ? 'locked' : 'unlocked'}." }
        format.json { { status: 'OK' } }
      else
        format.html { redirect_to course_forum_topic_path(@course, @forum, @topic),
                                  flash: { error: "The topic type could not be #{params[:lock] ? 'locked' : 'unlocked'}." } }
        format.json { { status: 'Error' } }
      end
    end
  end

  def set_hide
    authorize! :edit, @topic
    @topic.hidden = params[:hide]

    respond_to do |format|
      if @topic.save then
        format.html { redirect_to course_forum_topic_path(@course, @forum, @topic),
                                  notice: "The topic was was successfully #{params[:hide] ? 'hidden' : 'shown'}." }
        format.json { { status: 'OK' } }
      else
        format.html { redirect_to course_forum_topic_path(@course, @forum, @topic),
                                  flash: { error: "The topic type could not be #{params[:hide] ? 'hidden' : 'shown'}." } }
        format.json { { status: 'Error' } }
      end
    end
  end


  def destroy
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to course_forum_path(@course, @forum),
                                notice: 'The topic was successfully deleted.'}
    end
  end

private
  def load_forum
    @forum = ForumForum.find_using_slug(params[:forum_id])
  end

  def load_topic
    @topic = ForumTopic.find_using_slug(params[:id] || params[:topic_id])
    if %w(new create).include?(params[:action])
      @topic = ForumTopic.new
      # No implicit assignment of attributes to the @post property. We need to create the post first before
      # creating the topic.
    end
  end
end
