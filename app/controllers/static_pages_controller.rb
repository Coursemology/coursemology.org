class StaticPagesController < ApplicationController
  def welcome
    @courses = Course.limit(10)
  end

  def about
  end

  def access_denied
    if current_user && session[:request_url] && request.url == access_denied_url && session[:request_url] != request.url
      url = session[:request_url]
      session[:request_url] = nil
      redirect_to url
    end
  end
end
