Forem::Admin::BaseController.class_eval do
  def authenticate_forem_admin
    if @course.blank?
      if params[:course_id]
        @course = Course.find(params[:course_id])
      elsif params[:id]
        @course = Course.find(Forem::Forum.find(params[:id]).category.id)
      else
        @course = Course.find(params[:forum][:category_id])
      end
    end
    
    if !(can? :manage, Course)
      flash.alert = t("forem.errors.access_denied")
      redirect_to main_app.course_forums_path(@course)
    end
  end
end