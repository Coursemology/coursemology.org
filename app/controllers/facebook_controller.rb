class FacebookController < ApplicationController
  def obtain_badge
    get_fb_app_namespace

    @graph = Koala::Facebook::API.new(session[:fb_access_token])
    begin
      @graph.put_connections("me", "#{@app_namespace}:obtain", :badge => params[:facebook_obj_id], "fb:explicitly_shared" => true)
    rescue Koala::Facebook::APIError => e
      # catch and log errors posting to the fb
      logger.error e.fb_error_message
      # TODO: might be able to improve user experience by redirecting
      # and asking for permission
    end

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
