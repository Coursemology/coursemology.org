Forem::PostsController.class_eval do
  before_filter :find_forum
  def new
    @post = @topic.posts.build
    find_reply_to_post

    @post.text = view_context.forem_quote(@reply_to_post.text) if params[:quote]
    @course = Course.find(@forum.category.id)
    load_general_course_data
  end

  def create
    @post = @topic.posts.build(params[:post])
    @post.user = forem_user
    @course = Course.find(@forum.category.id)
    load_general_course_data

    if @post.save
      create_successful
    else
      create_failed
    end
  end

  def edit
    @course = Course.find(@forum.category.id)
    load_general_course_data
  end

  def update
    @course = Course.find(@forum.category.id)
    load_general_course_data
    if @post.owner_or_admin?(forem_user) && @post.update_attributes(params[:post])
      update_successful
    else
      update_failed
    end
  end

  def destroy
    @course = Course.find(@forum.category.id)
    load_general_course_data
    @post.destroy
    destroy_successful
  end

  private
  def find_forum
    @forum = Forem::Forum.find(@topic.forum_id)
    authorize! :read, @forum
  end
end