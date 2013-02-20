class CommentsController < ApplicationController
  load_and_authorize_resource :course

  def create
    @comment = Comment.new(params[:comment])
    @comment.user_course = curr_user_course
    authorize! :read, @comment.commentable
    if @comment.save
      @comment.commentable.notify_user(@comment, params[:origin])
      respond_to do |format|
        format.html { redirect_to params[:origin] }
      end
    end
  end
end
