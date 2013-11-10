Forem::ForumsController.class_eval do
  load_and_authorize_resource :forum
  append_before_filter :shim

  private

  def shim
    @course = Course.find(@forum.category.id)
    @current_ability = CourseAbility.new(current_user, curr_user_course)
    load_general_course_data
    ensure_logged_in
  end
end