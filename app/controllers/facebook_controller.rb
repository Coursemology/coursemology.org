class FacebookController < ApplicationController
  def obtain_badge
    get_fb_app_namespace
    @ask_for_permission = false
    @facebook_obj_id = params[:facebook_obj_id]

    @graph = Koala::Facebook::API.new(session[:fb_access_token])
    # check for publish_actions, permissions is of class GraphCollection
    # which extends Array, so need to index it first to get the hash
    permissions = @graph.get_connections("me", "permissions")
    if permissions[0]["publish_actions"].nil? 
      # initialize or increment counter which tracks how many times publish_actions has been requested
      if current_user.pub_ask_ctr.nil?
        current_user.pub_ask_ctr = 1
      else
        current_user.pub_ask_ctr += 1
      end

      # save new value of counter to database
      current_user.save!

      # no publish_actions, set instance variable which will be checked by JS later
      @ask_for_permission = true
    end

    # actual post will be handled by JS
    respond_to do |format|
      format.js
    end
  end

  private
    def get_fb_app_namespace
      oauth = Koala::Facebook::OAuth.new
      app_token = oauth.get_app_access_token
      graph = Koala::Facebook::API.new(app_token)
      @app_namespace = graph.get_connection("app", "")["namespace"]
    end
end
