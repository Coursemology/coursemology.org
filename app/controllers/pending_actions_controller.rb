class PendingActionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :pending_action, through: :course

  # GET /pending_actions
  # GET /pending_actions.json
  def index
    #@pending_actions = curr_user_course.pending_actions.to_show.select { |pa| pa.item.publish? and pa.item.open_at < Time.now }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pending_actions }
    end
  end

  def ignore
    @pending_action.is_ignored = true
    @pending_action.save

    respond_to do |format|
      #format.html # index.html.erb
      format.json { render json: {status: "OK"} }
    end
  end
end
