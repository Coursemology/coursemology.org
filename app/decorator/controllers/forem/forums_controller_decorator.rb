Forem::ForumsController.class_eval do
  load_and_authorize_resource :forum, :except => :mark_read
  append_before_filter :shim

  def mark_read
    #Forem::Topic.mark_as_read! :all, :for => current_user
    Forem::Post.mark_as_read! :all, :for => current_user
    redirect_to main_app.course_forum_path(@course, @forum)
  end

  private

  def shim
    unless @forum
      @forum = Forem::Forum.find(params[:forum_id])
    end
    @course = Course.find(@forum.category.id)
    @current_ability = CourseAbility.new(current_user, curr_user_course)
    load_general_course_data
    ensure_logged_in
  end
end