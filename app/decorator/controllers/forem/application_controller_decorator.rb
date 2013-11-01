Forem::ApplicationController.class_eval do
  def current_ability
    if @course
      @current_ability ||= CourseAbility.new(current_user, curr_user_course)
    else
      @current_ability ||= Forem::Ability.new(forem_user)
    end
  end
end