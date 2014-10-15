class RegistrationsController < Devise::RegistrationsController
  def new

    build_resource({})
    @token = params[:_token]

    if @token and std = MassEnrollmentEmail.find_by_confirm_token(@token)
      if std.signed_up?
        #token has been used
        @token = nil
      else
        self.resource.name = std.name
        self.resource.email =std.email
      end
    end
    respond_with self.resource
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

  def after_update_path_for(resource)
    main_app.users_settings_path
  end
end
