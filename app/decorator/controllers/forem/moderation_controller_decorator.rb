Forem::ModerationController.class_eval do
  before_filter :shim

  private

  def shim
    #@category ||= Forem::Category.find(@course.id)
    @forum ||= Forem::Forum.find(params[:forum_id])
    @category = Forem::Category.find(@forum.category_id)
    @course = Course.find(@category.id)
    @current_ability = CourseAbility.new(current_user, curr_user_course)
    load_general_course_data
    @current_ability = Forem::Ability.new(forem_user)
  end
end