class FacebookController < ApplicationController
  def obtain_badge
    get_fb_app_namespace
    @ask_for_permission = false
    @facebook_obj_id = params[:facebook_obj_id]

    if !current_user.can_publish_to_fb?(session[:fb_access_token])
      # Increment counter which tracks how many times publish_actions has been requested
      current_user.fb_publish_actions_request_count += 1

      # no publish_actions, set instance variable which will be checked by JS later
      @ask_for_permission = true
    else
      # reset publish_actions request counter when permission has been used
      #
      # Edge case exists if user grants permission on the 3rd request and revokes it immediately.
      # That post will be successful but as fb_publish_actions_request_count == 3 and there is no publish_actions permission,
      # the 'Share' button will not be displayed again.
      #
      # The counter is reset here to prevent this happening if permission is revoked immediately after
      # the 1st or 2nd request is granted.
      current_user.fb_publish_actions_request_count = 0
    end

    # save new value of counter to database here as all paths through the if statement above
    # modify it
    current_user.save!

    # actual facebook post will be handled by JS
    respond_to do |format|
      format.js
    end
  end

  private
    # sets up the instance variable for the FB JS SDK in the response
    def get_fb_app_namespace
      oauth = Koala::Facebook::OAuth.new
      app_token = oauth.get_app_access_token
      graph = Koala::Facebook::API.new(app_token)
      @app_namespace = graph.get_connection("app", "")["namespace"]
    end
end
