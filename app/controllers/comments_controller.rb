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
      @comment.commentable.notify_user(@comment, params[:origin])
      respond_to do |format|
        format.html { redirect_to params[:origin] }
      end
    end
  end

  def index

    @topics = @course.std_answers.accessible_by(current_ability).where("last_commented_at IS NOT NULL")
                        .order("last_commented_at DESC").page(params[:page]).per(3)
  end
end
