class ExpTransactionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :user_course


  before_filter :load_general_course_data

  def show
    @exp_transactions = @user_course.exp_transactions.accessible_by(current_ability).order("created_at DESC")
    @user = @user_course.user
  end
end
