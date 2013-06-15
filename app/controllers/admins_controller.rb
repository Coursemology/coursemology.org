class AdminsController < ApplicationController
  def initialize
    @admin = true
    super
  end
  def show
    logger.info "admin show"
  end
end
