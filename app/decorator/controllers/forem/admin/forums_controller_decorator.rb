Forem::Admin::ForumsController.class_eval do
  load_and_authorize_resource :course, :only => [:show, :new]
  before_filter :shim, :only => [:show, :new]

  def show
    if @course
      @forums = Forem::Forum.where(:category_id => @course.id)
    else
      @forums = Forem::Forum.all
    end
    render "forem/admin/forums/index"
  end

  def new
    @forum = Forem::Forum.new
  end

  private

  def shim
    @category ||= Forem::Category.find(@course.id)
    @current_ability = CourseAbility.new(current_user, curr_user_course)
    load_general_course_data
  end

  private

  def create_successful
    flash[:notice] = t("forem.admin.forum.created")
    @course = Course.find(@forum.category_id)
    redirect_to main_app.course_forums_admin_path(@course)
  end

  def destroy_successful
    flash[:notice] = t("forem.admin.forum.deleted")
    @course = Course.find(@forum.category_id)
    redirect_to main_app.course_forums_admin_path(@course)
  end

  def update_successful
    flash[:notice] = t("forem.admin.forum.updated")
    @course = Course.find(@forum.category_id)
    redirect_to main_app.course_forums_admin_path(@course)
  end
end