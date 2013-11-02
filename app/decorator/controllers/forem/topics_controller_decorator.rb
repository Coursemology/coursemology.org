Forem::TopicsController.class_eval do
  load_and_authorize_resource :forum

  before_filter :shim

  protected

  def create_successful
    redirect_to main_app.course_forum_topic_url(@course, @forum, @topic), :notice => t("forem.topic.created")
  end

  def destroy_successful
    flash[:notice] = t("forem.topic.deleted")

    redirect_to main_app.course_forum_url(@course, @forum)
  end

  def destroy_unsuccessful
    flash.alert = t("forem.topic.cannot_delete")

    redirect_to main_app.course_forum_url(@course, @forum)
  end

  def subscribe_successful
    flash[:notice] = t("forem.topic.subscribed")
    redirect_to main_app.course_forum_topic_url(@course, @forum, @topic)
  end

  def unsubscribe_successful
    flash[:notice] = t("forem.topic.unsubscribed")
    redirect_to main_app.course_forum_topic_url(@course, @forum, @topic)
  end

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

  def find_topic
    begin
      @topic = forum_topics(@forum, forem_user).find(params[:id])
      authorize! :read, @topic
    rescue ActiveRecord::RecordNotFound
      flash.alert = t("forem.topic.not_found")
      redirect_to main_app.course_forum_url(@course, @forum) and return
    end
  end
end