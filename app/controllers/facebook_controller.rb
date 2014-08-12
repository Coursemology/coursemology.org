class FacebookController < ApplicationController
  def obtain_badge
    @graph = Koala::Facebook::API.new(session[:fb_access_token])
    @graph.put_connections("me", "fonglh-coursemology:obtain", :badge => params[:facebook_obj_id], "fb:explicitly_shared" => true)

    respond_to do |format|
      format.js
    end
  end
end
