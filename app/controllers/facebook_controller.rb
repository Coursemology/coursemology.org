class FacebookController < ApplicationController
  def obtain_badge
    get_fb_app_namespace

    @graph = Koala::Facebook::API.new(session[:fb_access_token])
    @graph.put_connections("me", "#{@app_namespace}:obtain", :badge => params[:facebook_obj_id], "fb:explicitly_shared" => true)

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
