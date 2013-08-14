class ExpTransactionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :user_course
  load_and_authorize_resource :exp_transaction


  before_filter :load_general_course_data

  def index
    @exp_transactions = @user_course.exp_transactions.accessible_by(current_ability).order("created_at DESC")
  end

  def destroy
    @exp_transaction.destroy
    flash[:notice] = "EXP transaction has been successfully deleted and deducted from student's EXP sum."
    redirect_to course_user_course_exp_transactions_path
  end
end
