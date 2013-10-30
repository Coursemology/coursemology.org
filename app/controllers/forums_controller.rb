class ForumsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :class => 'Forem::Forum', :only => :show

  before_filter :load_general_course_data, only: [:index, :show]

  private

  def authenticate_forem_user
    if !forem_user
      session["user_return_to"] = request.fullpath
      flash.alert = t("forem.errors.not_signed_in")
      devise_route = "new_#{Forem.user_class.to_s.underscore}_session_path"
      sign_in_path = Forem.sign_in_path ||
          (main_app.respond_to?(devise_route) && main_app.send(devise_route)) ||
          (main_app.respond_to?(:sign_in_path) && main_app.send(:sign_in_path))
      redirect_to sign_in_path
    end
  end

  def forem_admin?
    forem_user && forem_user.forem_admin?
  end
  helper_method :forem_admin?

  def forem_admin_or_moderator?(forum)
    forem_user && (forem_user.forem_admin? || forum.moderator?(forem_user))
  end
  helper_method :forem_admin_or_moderator?

  #def authorize
  #  if curr_user_course.is_staff?
  #    return true
  #  end
  #
  #  can_start = @mission.can_start?(curr_user_course).first
  #  unless can_start
  #    redirect_to course_mission_access_denied_path(@course, @mission)
  #  end
  #end

end
