class StaticPagesController < ApplicationController
  def welcome
    #@courses = Course.online_course.limit(10)
  end

  def about
  end

  def privacy_policy
  end

  def contact_us

  end

  def help

  end

  def access_denied
    if current_user && session[:request_url] && request.url == access_denied_url && session[:request_url] != request.url
      url = session[:request_url]
      session[:request_url] = nil
      redirect_to url
    end
  end
end
