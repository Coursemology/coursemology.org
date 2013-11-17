Forem::CategoriesController.class_eval do
  append_before_filter :shim
  skip_authorize_resource :only => [:subscribe, :unsubscribe]

  def mark_read
    unread = Forem::Post.joins(topic: {forum: :category}).unread_by(current_user).where('forem_categories.id' => @course.id)
    if unread.count > 0
      Forem::Post.mark_as_read! unread.all, :for => current_user
    end
    unread = Forem::Topic.joins(forum: :category).unread_by(current_user).where('forem_categories.id' => @course.id)
    if unread.count > 0
        Forem::Topic.mark_as_read! unread.all, :for => current_user
    end
    redirect_to main_app.course_forums_url(@course)
  end

  def subscribe
    digest = params[:digest] ? true : false

    subscription = Forem::CategorySubscription.where(subscriber_id: current_user.id, category_id: @course.id).first
    if subscription
      subscription.is_digest = digest
      subscription.save
    else
      Forem::CategorySubscription.create(subscriber_id: current_user.id, category_id: @course.id, is_digest: digest)
    end
    if digest
      flash[:notice] = "Subscribed, you will receive daily summary of new posts."
    else
      flash[:notice] = "Subscribed, you will be notified of new posts via email."
    end

    redirect_to main_app.course_forums_url(@course)
  end

  def unsubscribe
    Forem::CategorySubscription.where('subscriber_id = ? AND category_id = ?', current_user.id, @course.id).each do |s|
      s.destroy
    end
    flash[:notice] = "Unsubscribed, you will no longer receive email notifications."
    redirect_to main_app.course_forums_url(@course)
  end

  private

  def shim
    @course = Course.find(params[:course_id])
    @category = Forem::Category.find(@course.id)
    @current_ability = CourseAbility.new(current_user, curr_user_course)
    load_general_course_data
    ensure_logged_in
  end
end