Forem::TopicsController.class_eval do
  def show
    if find_topic
      @posts = find_posts(@topic).page(params[:page]).per(Forem.per_page)
      @course = Course.find(@forum.category.id)
      load_general_course_data
    end
  end

  def new
    authorize! :create_topic, @forum
    @topic = @forum.topics.build
    @topic.posts.build
    @course = Course.find(@forum.category.id)
    load_general_course_data
  end

  def create
    authorize! :create_topic, @forum
    @topic = @forum.topics.build(params[:topic], :as => :default)
    @topic.user = forem_user
    @course = Course.find(@forum.category.id)
    load_general_course_data
    if @topic.save
      create_successful
    else
      create_unsuccessful
    end
  end

  def destroy
    @topic = @forum.topics.find(params[:id])
    @course = Course.find(@forum.category.id)
    load_general_course_data
    if forem_user == @topic.user || forem_user.forem_admin?
      @topic.destroy
      destroy_successful
    else
      destroy_unsuccessful
    end
  end

  def subscribe
    @course = Course.find(@forum.category.id)
    load_general_course_data
    if find_topic
      @topic.subscribe_user(forem_user.id)
      subscribe_successful
    end
  end
end