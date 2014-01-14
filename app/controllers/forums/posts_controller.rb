class Forums::PostsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, only: [:reply, :edit]

  before_filter :load_forum
  load_and_authorize_resource :forum
  before_filter :load_topic
  load_and_authorize_resource :topic
  before_filter :load_post
  load_and_authorize_resource :post, class: 'ForumPost'

  def create
    if @topic.locked? then
      flash[:error] = 'Cannot reply to the given post because it is locked.'
      redirect_to course_forum_topic_path(@course, @forum, @topic) and return
    end

    authorize! :reply, @topic

    parent = ForumPost.find_by_id!(params[:forum_post][:parent_id])
    @post.topic = @topic
    @post.parent = parent
    @post.author = curr_user_course

    respond_to do |format|
      if @post.save
        format.html { redirect_to course_forum_topic_path(@course, @forum, @topic, anchor: "post-#{@post.id}"),
                                  notice: 'The post was successfully created.' }
      else
        redirect_to course_forum_topic_path(@course, @forum, @topic)
      end
    end
  end

  def edit

  end

  def update
    @post.assign_attributes(params[:forum_post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to course_forum_topic_path(@course, @forum, @topic, anchor: "post-#{@post.id}"),
                                  notice: 'The post was successfully saved.' }
      else
        redirect_to course_forum_topic_path(@course, @forum, @topic)
      end
    end
  end

  def destroy
    @post.destroy

    respond_to do |format|
      path = @topic.posts.empty? ? course_forum_path(@course, @forum) : course_forum_topic_path(@course, @forum, @topic)
      format.html { redirect_to path,
                                notice: "The post was successfully deleted." }
    end
  end

  def reply
    authorize! :reply, @topic
  end

  def set_vote
    case params[:vote].to_i <=> 0
      when -1
        @post.downvote_from curr_user_course.user
      when 0
        @post.unvote_for curr_user_course.user
      when 1
        @post.upvote_from curr_user_course.user
    end

    respond_to do |format|
      format.html { redirect_to course_forum_topic_path(@course, @forum, @topic, anchor: ('post-' + @post.id.to_s)) }
    end
  end

  def set_answer
    @post.answer = params[:answer].to_i != 0

    respond_to do |format|
      if @post.save then
        format.html { redirect_to course_forum_topic_path(@course, @forum, @topic, anchor: ('post-' + @post.id.to_s)) }
      end
    end
  end

private
  def load_forum
    @forum = ForumForum.find_using_slug(params[:forum_id])
    raise ActiveRecord::RecordNotFound unless @forum
  end

  def load_topic
    @topic = ForumTopic.find_using_slug(params[:topic_id])
    raise ActiveRecord::RecordNotFound unless @topic
  end

  def load_post
    @post = ForumPost.find_by_id(params[:id] || params[:post_id])
    if %w(new create).include?(params[:action])
      @post = ForumPost.new
      @post.assign_attributes(params[:forum_post])
    end

    raise ActiveRecord::RecordNotFound unless @post
  end
end
