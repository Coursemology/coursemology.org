Forem::TopicsController.class_eval do
  load_and_authorize_resource :forum
  skip_before_filter :block_spammers
  append_before_filter :shim

  def next_unread
    unread = Forem::Post.unread_by(current_user).select { |p| p.topic != @topic }
    unread = unread.select { |p| p.topic.forum.id == @forum.id }
    if unread.count > 0
      redirect_to main_app.course_forum_topic_url(@course, @forum, unread.first.topic)
    else
      redirect_to main_app.course_forum_topic_url(@course, @forum, @topic)
    end
  end

  def new
    @topic = @forum.topics.build
    @topic.posts.build
  end

  def create
    @topic = @forum.topics.build(params[:topic], :as => :default)
    @topic.user = forem_user
    if @topic.save
      create_successful
    else
      create_unsuccessful
    end
  end

  def destroy
    @topic = @forum.topics.find(params[:id])
    if forem_user == @topic.user || curr_user_course.is_staff?
      @topic.destroy
      destroy_successful
    else
      destroy_unsuccessful
    end
  end

  protected

  def create_successful
    redirect_to main_app.course_forum_topic_url(@course, @forum, @topic), :notice => t("forem.topic.created")
  end

  def destroy_successful
    flash[:notice] = t("forem.topic.deleted")

    redirect_to main_app.course_forum_url(@course, @forum)
  end

  def destroy_unsuccessful
    flash.alert = t("forem.topic.cannot_delete")

    redirect_to main_app.course_forum_url(@course, @forum)
  end

  def subscribe_successful
    flash[:notice] = t("forem.topic.subscribed")
    redirect_to main_app.course_forum_topic_url(@course, @forum, @topic)
  end

  def unsubscribe_successful
    flash[:notice] = t("forem.topic.unsubscribed")
    redirect_to main_app.course_forum_topic_url(@course, @forum, @topic)
  end

  private

  def shim
    if !@topic and params[:id]
      @topic = Forem::Topic.find(params[:id])
    end

    @course = Course.find(@forum.category.id)
    @current_ability = CourseAbility.new(current_user, curr_user_course)
    load_general_course_data
    ensure_logged_in
  end

  def find_topic
    begin
      @topic = forum_topics(@forum, forem_user).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.alert = t("forem.topic.not_found")
      redirect_to main_app.course_forum_url(@course, @forum) and return
    end
  end
end