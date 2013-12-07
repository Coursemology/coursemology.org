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

private
  def load_forum
    @forum = ForumForum.find_using_slug(params[:forum_id])
  end

  def load_topic
    @topic = ForumTopic.find_using_slug(params[:id])
  end
end
