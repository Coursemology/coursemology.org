class CommentsController < ApplicationController
  load_and_authorize_resource :course

  before_filter :load_general_course_data, only: [:show, :index, :edit, :new]

  def create
    @comment = Comment.new(params[:comment])
    @comment.user_course = curr_user_course
    authorize! :read, @comment.commentable
    if @comment.save
      commentable = @comment.commentable
      commentable.last_commented_at = Time.now
      commentable.save
      @comment.commentable.notify_user(curr_user_course, @comment, params[:origin])
      respond_to do |format|
        #format.html { redirect_to params[:origin] }
        format.json {render json: @comment.commentable.comments_json}
      end
    end
  end

  def index
    if can? :see, :pending_comments
      @tab = params[:_tab]

      @pending_comments = @course.get_pending_comments
      @mine_pending_coments = get_mystudent_pending_comments

      case @tab
        when 'all'
          @topics = @course.get_all_comments
        when 'pending'
          @topics = @pending_comments
        when 'minepending'
          @topics = @mine_pending_coments
        when 'mine'
          @topics = get_mystudent_comments
        else
          @tab = 'pending'
          @topics = @pending_comments
      end
    else
      @topics = @course.get_all_comments_by_ability(current_ability)
    end

    @topics = sorting_and_paging(@topics)

  end

  def get_mystudent_pending_comments
    @topics = @course.get_pending_comments
    mystudents = curr_user_course.get_my_stds.map { |std| std.id }
    @topics = @topics.select { |ans| mystudents.include? ans.std_course_id }
  end

  def get_mystudent_comments
    @topics = @course.get_all_comments
    mystudents = curr_user_course.get_my_stds.map { |std| std.id }
    @topics = @topics.select { |ans| mystudents.include? ans.std_course_id }
  end

  def pending_toggle
    if !params[:cid] || !params[:ctype]
      return
    end
    pending_comment = PendingComments.find_by_answer_id_and_answer_type(params[:cid], params[:ctype])
    unless pending_comment
      pending_comment = PendingComments.create(answer_id:params[:cid], answer_type:params[:ctype],pending: false)
    end
    pending_comment.pending = !pending_comment.pending
    if pending_comment.save
      respond_to do |format|
        format.json {render json: {status: 'OK'}}
      end
    end
  end

  private
  def sorting_and_paging(topics)
    @topics = topics.sort_by { |ans| ans.last_commented_at }
    @topics = Kaminari.paginate_array(@topics).page(params[:page]).per(10)
  end
end
