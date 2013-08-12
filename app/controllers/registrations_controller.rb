class RegistrationsController < Devise::RegistrationsController
  def new
    @token = params[:_token]
    super
  end

  def create
    @token = params[:_token]
    super
    if resource.created_at && @token
       resource.auto_enroll_for_invited(@token)
    end
  end
  def edit
    @setting = true
  end

  def update
    @setting = true
    super
  end
end
