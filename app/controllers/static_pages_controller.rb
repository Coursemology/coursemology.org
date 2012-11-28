class StaticPagesController < ApplicationController
  def welcome
    @courses = Course.limit(10);
  end

  def about
  end

  def access_denied

  end
end
