Forem::CategoriesController.class_eval do
  append_before_filter :shim

  def mark_read
    unread = Forem::Post.joins(topic: {forum: :category}).unread_by(current_user).where('forem_categories.id' => @course.id)
    unread.each do |p|
      p.mark_as_read! :for => current_user
    end
    unread = Forem::Topic.joins(forum: :category).unread_by(current_user).where('forem_categories.id' => @course.id)
    unread.each do |t|
      t.mark_as_read! :for => current_user
    end
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