Forem::PostsController.class_eval do
  load_and_authorize_resource :topic
  skip_before_filter :block_spammers
  append_before_filter :shim

  def update
    if (@post.owner_or_admin?(forem_user) || curr_user_course.is_staff?) && @post.update_attributes(params[:post])
      update_successful
    else
      update_failed
    end
  end

  def like
    @post = Forem::Post.find(params[:post_id])
    @post.liked_by forem_user
    head :ok
  end

  def unlike
    @post = Forem::Post.find(params[:post_id])
    @post.unliked_by forem_user
    head :ok
  end

  private

  def shim
    @forum = @topic.forum
    @course = Course.find(@forum.category.id)
    @current_ability = CourseAbility.new(current_user, curr_user_course)
    load_general_course_data
    ensure_logged_in
  end

  def create_successful
    flash[:notice] = t("forem.post.created")
    redirect_to main_app.course_forum_topic_url(@course, @forum, @topic, :page => @topic.last_page)
  end

  def destroy_successful
    if @post.topic.posts.count == 0
      @post.topic.destroy
      flash[:notice] = t("forem.post.deleted_with_topic")
      redirect_to main_app.course_forum_url(@course, @forum)
    else
      flash[:notice] = t("forem.post.deleted")
      redirect_to main_app.course_forum_topic_url(@course, @forum, @topic)
    end
  end

  def update_successful
    redirect_to main_app.course_forum_topic_url(@course, @forum, @topic), :notice => t('edited', :scope => 'forem.post')
  end

  def ensure_post_ownership!
    unless @post.owner_or_admin? forem_user or can? :manage, Course
      flash[:alert] = t("forem.post.cannot_delete")
      redirect_to main_app.course_forum_topic_url(@course, @forum, @topic) and return
    end
  end

  def reject_locked_topic!
    if @topic.locked?
      flash.alert = t("forem.post.not_created_topic_locked")
      redirect_to main_app.course_forum_topic_url(@course, @forum, @topic) and return
    end
  end
end