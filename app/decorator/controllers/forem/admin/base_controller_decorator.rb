Forem::Admin::BaseController.class_eval do
  def authenticate_forem_admin
  	if @course.blank?
      @course = Course.find(params[:course_id])
    end
    
    if !(can? :manage, Forem)
      flash.alert = t("forem.errors.access_denied")
      redirect_to main_app.course_forums_path(@course)
    end
  end
end