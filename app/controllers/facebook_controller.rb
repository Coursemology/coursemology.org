class FacebookController < ApplicationController
  def obtain_badge
    @graph = Koala::Facebook::API.new(session[:fb_access_token])
    @graph.put_connections("me", "fonglh-coursemology:obtain", :badge => 269890349885321, "fb:explicitly_shared" => true)
  end
end
