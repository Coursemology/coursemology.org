JfdiAcademy::Application.routes.draw do

  # This line mounts Forem's routes at /forums by default.
  # This means, any requests to the /forums URL of your application will go to Forem::ForumsController#index.
  # If you would like to change where this extension is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Forem relies on it being the default of "forem"
  mount Forem::Engine, :at => '/forums'

  authenticated :user do
    root :to => "home#index"
  end

  root :to => "static_pages#welcome"
  get "welcome" => "static_pages#welcome"
  get "about" => "static_pages#about"
  get "privacy_policy" => "static_pages#privacy_policy"
  get "access_denied" => "static_pages#access_denied"
  get "contact_us" => "static_pages#contact_us"

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks",
                                       :registrations => "registrations" }

  get "users/settings" => "users#edit"
  put "users/update" => "users#update"

  post "user/auto_login" => "auto_login#auto_login_from_facebook"


  match "admins" => "admins#access_control"
  match "admins/search" => "admins#search"
  match "admins/masquerades" => 'admins#masquerades', as: :admin_masquerades
  #match "admin/access_control" => "admins#access_control"

  delete "admins/stop_masquerades" => "masquerades#destroy", as: :destroy_masquerades

  resources :users do
    resources :masquerades, only: [:new]
  end

  #match "admins/index" =>"admins#index"
  get "lecturers/request" => "role_requests#new"
  resources :role_requests

  resources :courses do
    match "/submissions" => "submissions#listall", as: :submissions
    match "/training_submissions" => "training_submissions#listall", as: :training_submissions

    match "/leaderboards"     => "leaderboards#show", as: :leaderboards
    match "/staff"            => "user_courses#staff", as: :staff
    match "/manage_group"  => "course_groups#manage_group", as: :manage_group
    post  "/add_student"      => "course_groups#add_student", as: :manage_add_student
    post  "/update_exp"        => "course_groups#update_exp", as: :manage_update_exp
    match "missions/overview" => "missions#overview", as: :missions_overview
    post  "missions/bulk_update" => "missions#bulk_update", as: :missions_bulk_update
    match "trainings/overview" => "trainings#overview", as: :trainings_overview
    post  "trainings/bulk_update" => "trainings#bulk_update", as: :trainings_bulk_update

    resources :user_courses do
      resources :exp_transactions
      resources :user_achievements
    end

    resources :missions do
      resources :mission_coding_questions, as: :coding_questions
      resources :questions
      resources :submissions do
        resources :submission_gradings
      end
      post "submissions/:id/unsubmit" => "submissions#unsubmit", as: :submissions_unsubmit

      resources :asm_qns do
        collection do
          post 'reorder'
        end
      end
    end
    match "missions/:id/stats" => "missions#stats", as: :mission_stats
    match "missions/:id/dump_code" => "missions#dump_code", as: :mission_dump_code

    resources :trainings do
      resources :mcqs
      resources :coding_questions
      resources :training_submissions
      post "training_submissions/:id/submit" => "training_submissions#submit", as: :training_submission_submit

      resources :asm_qns do
        collection do
          post 'reorder'
        end
      end
    end
    match "trainings/:id/stats" => "trainings#stats", as: :training_stats

    resources :mcq_answers

    resources :announcements

    post "levels/populate" => "levels#populate", as: :levels_populate
    post "levels/mass_update" => "levels#mass_update", as: :levels_mass_update
    match "missions/:id/access_denied" => "missions#access_denied", as: :mission_access_denied
    match "trainings/:id/access_denied" => "trainings#access_denied", as: :training_access_denied

    resources :levels

    resources :achievements

    resources :requirements

    post "requirements/render_form_row" => "requirements#render_form_row"

    resources :file_uploads

    match "enroll_requests/approve_all" => "enroll_requests#approve_all", as: :enroll_request_approve_all

    match "enroll_requests/approve_selected" => "enroll_requests#approve_selected", as: :enroll_request_approve_selected

    match "enroll_requests/delete_all" => "enroll_requests#delete_all", as: :enroll_request_delete_all

    match "enroll_requests/delete_selected" => "enroll_requests#delete_selected", as: :enroll_request_delete_selected

    resources :enroll_requests

    resources :tags

    resources :tag_groups

    resources :asm_tags

    post "asm_tags/render_form_row" => "asm_tags#render_form_row"

    match "/comments/question" => "comments#view_for_question", as: :comments_question
    resources :comments
    post "/comments/toggle" => "comments#pending_toggle"
    post "/comments/get_comments" => "comments#get_comments"

    resources :annotations

    get "stats" => "stats#general"

    get "stats/missions/:mission_id" => "stats#mission", as: :stats_mission

    get "stats/trainings/:training_id" => "stats#training", as: :stats_training

    get "duplicate" => "duplicate#manage", as: :duplicate

    get "duplicate_course" => "duplicate#duplicate_course", as: :duplicate_course

    get "duplicate_assignments" => "duplicate#duplicate_assignments", as: :duplicate_assignments

    match "award_exp" => "manual_rewards#manual_exp", as: :manual_exp

    match "award_achievement" => "manual_rewards#manual_achievement", as: :manual_achievement

    match "remove_achievement" => "manual_rewards#remove_achievement", as: :remove_achievement

    get "preferences" => "course_preferences#edit", as: :preferences

    post "preferences" => "course_preferences#update", as: :preferences

    resources :mass_enrollment_emails

    post "send_enrollment_emails" => "mass_enrollment_emails#send_enroll_emails"
    match "resend_enrollment_emails" => "mass_enrollment_emails#resend_emails"
    match "delete_enrollment_invitations" => "mass_enrollment_emails#delete_mass"

    resources :student_summary

    resources :staff_leaderboard

    resources :surveys do
      resources :survey_questions
      resources :survey_submissions
      post "survey_submissions/:id/submit" => "survey_submissions#submit", as: :survey_submission_submit
    end

    match "surveys/:id/stats" => "surveys#stats", as: :survey_stats
    match "surveys/:id/summary" => "surveys#summary", as: :survey_summary

    get "staff_monitoring" => "staff_leaderboard#monitoring", as: :staff_monitoring

    match "forum_participation" => "forum_participation#manage", as: :forum_participation
    match "forum_participation/user/:poster_id" => "forum_participation#individual", as: :forum_participation_individual
    match "/forums" => "forem/categories#show", as: :forums
    match "/forums/manage" => "forem/admin/forums#show", as: :forums_admin
    match "/forums/new" => "forem/admin/forums#new", as: :forums_admin_new
    match "/forums/mark_read" => "forem/categories#mark_read", as: :forums_mark_read
    match "/forums/:id/edit" => "forem/admin/forums#edit", as: :forums_admin_edit
    match "/forums/:forum_id/topics/:id/edit" => "forem/admin/topics#edit", as: :forums_topics_admin_edit
    put "/forums/:forum_id/topics/:id/toggle_hide" => "forem/admin/topics#toggle_hide", as: :forums_topics_admin_hide
    put "/forums/:forum_id/topics/:id/toggle_lock" => "forem/admin/topics#toggle_lock", as: :forums_topics_admin_lock
    put "/forums/:forum_id/topics/:id/toggle_pin" => "forem/admin/topics#toggle_pin", as: :forums_topics_admin_pin
    resources :forums, :controller => "forem/forums" do
      resources :topics, :controller => "forem/topics" do
        resources :posts, :controller => "forem/posts" do
          get :like
          get :unlike
        end
        get :subscribe
        get :unsubscribe
        get :mark_read
        get :next_unread
      end
      get :mark_read
      get :next_unread
    end
  end

  match "courses/:id/students" => "courses#students", as: :course_students
  match "courses/:id/manage_students" => "courses#manage_students", as: :course_manage_students
  match "courses/:id//pending_gradings"   => "courses#pending_gradings", as: :course_pending_gradings

  resources :file_uploads

  resources :trainings do
    resources :file_uploads
  end

  resources :missions do
    resources :file_uploads
  end

  resources :submissions do
    resources :file_uploads
  end

  resources :survey_questions do
    resources :file_uploads
  end

end
