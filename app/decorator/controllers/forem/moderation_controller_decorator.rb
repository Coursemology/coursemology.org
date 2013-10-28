Forem::ModerationController.class_eval do
  def index
    @posts = forum.posts.pending_review.topic_not_pending_review
    @topics = forum.topics.pending_review
    @course = Course.find(@forum.category.id)
    load_general_course_data
  end

  def posts
    @course = Course.find(@forum.category.id)
    load_general_course_data
    Forem::Post.moderate!(params[:posts] || [])
    flash[:notice] = t('forem.posts.moderation.success')
    redirect_to :back
  end

  def topic
    @course = Course.find(@forum.category.id)
    load_general_course_data
    if params[:topic]
      topic = forum.topics.find(params[:topic_id])
      topic.moderate!(params[:topic][:moderation_option])
      flash[:notice] = t("forem.topic.moderation.success")
    else
      flash[:error] = t("forem.topic.moderation.no_option_selected")
    end
    redirect_to :back
  end
end