Forem::CategoriesController.class_eval do
  load_and_authorize_resource :course
  before_filter :shim

  private

  def shim
    @category ||= Forem::Category.find(@course.id)
    @current_ability = CourseAbility.new(current_user, curr_user_course)
    load_general_course_data
    @current_ability = Forem::Ability.new(forem_user)
  end
end