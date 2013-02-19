class CommentsController < ApplicationController
  load_and_authorize_resource :course

  def create
    @comment = Comment.new(params[:comment])
    @comment.user_course = curr_user_course
    puts @comment.commentable.to_json
    puts can?(:read, @comment.commentable)
    authorize! :read, @comment.commentable
    @comment.save
    respond_to do |format|
      format.html { redirect_to params[:origin] }
    end
  end
end
