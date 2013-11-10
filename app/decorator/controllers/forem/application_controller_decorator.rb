Forem::ApplicationController.class_eval do
  def current_ability
    if @course
      @current_ability ||= CourseAbility.new(current_user, curr_user_course)
    else
      @current_ability ||= Forem::Ability.new(forem_user)
    end
  end

  def forem_admin?
    can? :manage, Forem
  end
  helper_method :forem_admin?

  def forem_admin_or_moderator?(forum)
    can? :manage, Forem
  end
  helper_method :forem_admin_or_moderator?

  protected

  def ensure_logged_in
    if @course
      unless curr_user_course.is_student? || (can? :manage, Forem)
        redirect_to main_app.course_url(@course)
      end
    end
  end
end