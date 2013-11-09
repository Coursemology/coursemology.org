Forem::CategoriesController.class_eval do
  append_before_filter :shim

  private

  def shim
    @course = Course.find(params[:course_id])
    @category = Forem::Category.find(@course.id)
    @current_ability = CourseAbility.new(current_user, curr_user_course)
    load_general_course_data
    ensure_logged_in
  end
end