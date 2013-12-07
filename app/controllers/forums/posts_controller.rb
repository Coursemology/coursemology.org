class Forums::PostsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, only: [:edit]

  before_filter :load_forum
  load_and_authorize_resource :forum
  before_filter :load_topic
  load_and_authorize_resource :topic
  before_filter :load_post
  load_and_authorize_resource :post

  def create
    parent = ForumPost.find_by_id!(params[:parent_id])
    @post.parent = parent

    respond_to do |format|
      if @post.save
        format.html { redirect_to course_forum_topic_path(@course, @forum, @topic, anchor: "post-#{@post.id}"),
                                  notice: 'The post was successfully created' }
      else
        redirect_to course_forum_topic_path(@course, @forum, @topic)
      end
    end
  end

  def edit

  end

  def update

  end

  def destroy

  end

  def set_vote

  end

private
  def load_forum
    @forum = ForumForum.find_using_slug(params[:forum_id])
  end

  def load_topic
    @topic = ForumTopic.find_using_slug(params[:topic_id])
  end

  def load_post
    @post = ForumPost.find_by_id(params[:id])
    @post = ForumPost.create unless @post
  end
end
