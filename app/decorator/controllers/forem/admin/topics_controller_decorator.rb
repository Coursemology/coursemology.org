Forem::Admin::TopicsController.class_eval do
  load_and_authorize_resource :course
  load_and_authorize_resource :class => "Forem::Forum"
  load_and_authorize_resource :class => "Forem::Topic"
  before_filter :shim

  def update
    if @topic.update_attributes(params[:topic], :as => :admin)
      flash[:notice] = t("forem.topic.updated")
      redirect_to main_app.course_forum_topic_path(@course, @topic.forum, @topic)
    else
      flash.alert = t("forem.topic.not_updated")
      render :action => "edit"
    end
  end

  def destroy
    forum = @topic.forum
    @topic.destroy
    flash[:notice] = t("forem.topic.deleted")
    redirect_to main_app.course_forum_path(@course, forum)
  end

  def toggle_hide
    @topic.toggle!(:hidden)
    flash[:notice] = t("forem.topic.hidden.#{@topic.hidden?}")
    redirect_to main_app.course_forum_topic_path(@course, @topic.forum, @topic)
  end

  def toggle_lock
    @topic.toggle!(:locked)
    flash[:notice] = t("forem.topic.locked.#{@topic.locked?}")
    redirect_to main_app.course_forum_topic_path(@course, @topic.forum, @topic)
  end

  def toggle_pin
    @topic.toggle!(:pinned)
    flash[:notice] = t("forem.topic.pinned.#{@topic.pinned?}")
    redirect_to main_app.course_forum_topic_path(@course, @topic.forum, @topic)
  end

  private

  def shim
    @category ||= Forem::Category.find(@course.id)
    @current_ability = CourseAbility.new(current_user, curr_user_course)
    load_general_course_data
  end
end