Forem::PostsController.class_eval do
  load_and_authorize_resource :topic

  before_filter :shim

  private

  def shim
    @forum = Forem::Forum.find(params[:forum_id])
    @course = Course.find(@forum.category.id)
    @current_ability = CourseAbility.new(current_user, curr_user_course)
    load_general_course_data
    @current_ability = Forem::Ability.new(forem_user)
  end
end