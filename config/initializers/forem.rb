Forem.user_class = "User"
Forem.email_from_address = Devise.mailer_sender
# If you do not want to use gravatar for avatars then specify the method to use here:
# Forem.avatar_user_method = :custom_avatar_url
Forem.per_page = 20
Forem.moderate_first_post = false

Rails.application.config.to_prepare do
#   If you want to change the layout that Forem uses, uncomment and customize the next line:
#   Forem::ApplicationController.layout "forem"
#
#   If you want to add your own cancan Abilities to Forem, uncomment and customize the next line:
  Forem::Ability.register_ability(Ability)
  Forem.formatter = CoursemologyFormatter
end
#
# By default, these lines will use the layout located at app/views/layouts/forem.html.erb in your application.
