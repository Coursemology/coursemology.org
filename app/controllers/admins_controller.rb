class AdminsController < ApplicationController
  before_filter :signed_in_user
  def initialize
    @admin = true
    super
  end
  def show
    #logger.info "admin show"
  end
end
