class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end
  def edit
    @setting = true
  end

  def update
    @setting = true
    super
  end
end
