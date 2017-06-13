class RegistrationsController < Devise::RegistrationsController
  def new
    # build_resource({})
    # @token = params[:_token]
    #
    # if @token and std = MassEnrollmentEmail.find_by_confirm_token(@token)
    #   if std.signed_up?
    #     #token has been used
    #     @token = nil
    #   else
    #     self.resource.name = std.name
    #     self.resource.email =std.email
    #   end
    # end
    # respond_with self.resource

    flash[:error] = "We are not allowing the creation of users in this system any more, please go to the new Coursemology site at https://beta.coursemology.org/ to create new accounts or login with your existing accounts."
    redirect_to root_path
  end

  def create
    # @token = params[:_token]
    # super
    # if resource.created_at && @token
    #   resource.auto_enroll_for_invited(@token)
    # end
    flash[:error] = "We are not allowing the creation of users in this system any more, please go to the new Coursemology site at https://beta.coursemology.org/ to create new accounts or login with your existing accounts."
    redirect_to root_path
  end

  def edit
    @setting = true
  end

  def update
    flash[:error] = "Updating of users in current system has been disabled, please log in with your current account at https://beta.coursemology.org and update there."
    redirect_to edit_user_path(current_user)
  end

  def after_update_path_for(resource)
    main_app.users_settings_path
  end
end
