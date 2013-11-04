Forem::Admin::BaseController.class_eval do
  def authenticate_forem_admin
    if !(can? :manage, Course)
      flash.alert = t("forem.errors.access_denied")
      redirect_to main_app.course_forums_path(@course)
    end
  end
end