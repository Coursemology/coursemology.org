Forem::ForumsController.class_eval do
  def show
    @topics = if forem_admin_or_moderator?(@forum)
      @forum.topics
    else
      @forum.topics.visible.approved_or_pending_review_for(forem_user)
    end

    @topics = @topics.by_pinned_or_most_recent_post.page(params[:page]).per(Forem.per_page)
    @course = Course.find(@forum.category.id)
    load_general_course_data

    respond_to do |format|
      format.html
      format.atom { render :layout => none }
    end
  end
end