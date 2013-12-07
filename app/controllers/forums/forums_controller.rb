class Forums::ForumsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, except: [:destroy]

  before_filter :load_forum, except: [:index]
  load_and_authorize_resource :forum

  def index
    @forums = @course.forums
  end

  def show
    @topics = @forum.topics.accessible_by(current_ability)
    @topics = @topics.page(params[:page]).per(@course.forum_paging_pref.prefer_value.to_i)
  end

private
  def load_forum
    @forum = ForumForum.find_using_slug(params[:id])
  end
end
