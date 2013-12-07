class Forums::TopicsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, except: [:destroy]

  before_filter :load_forum
  load_and_authorize_resource :forum
  before_filter :load_topic
  load_and_authorize_resource :topic

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
                                notice: 'The topic was successfully created' }
    end
  end

private
  def load_forum
    @forum = ForumForum.find_using_slug(params[:forum_id])
  end

  def load_topic
    @topic = ForumTopic.find_using_slug(params[:id])
    if %w(new create).include?(params[:action])
      @topic = ForumTopic.new
      # No implicit assignment of attributes to the @post property. We need to create the post first before
      # creating the topic.
    end
  end
end
