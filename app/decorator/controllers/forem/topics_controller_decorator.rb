Forem::TopicsController.class_eval do
  load_and_authorize_resource :forum

  before_filter :shim

  private

  def shim
    if !@topic and params[:id]
      @topic = Forem::Topic.find(params[:id])
    end

    @course = Course.find(@forum.category.id)
    @current_ability = CourseAbility.new(current_user, curr_user_course)
    load_general_course_data
    @current_ability = Forem::Ability.new(forem_user)
  end
end