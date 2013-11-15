Forem::CategoriesController.class_eval do
  append_before_filter :shim

  def mark_read
    unread = Forem::Post.joins(topic: {forum: :category}).unread_by(current_user).where('forem_categories.id' => @course.id)
    if unread.count > 0
      Forem::Post.mark_as_read! unread.all, :for => current_user
    end
    redirect_to main_app.course_forums_url(@course)
  end

  def subscribe_new_topic
    flash[:notice] = "Subscribed"
    redirect_to main_app.course_achievements_url(@course)
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