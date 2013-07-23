JfdiAcademy::Application.routes.draw do

  authenticated :user do
    root :to => "home#index"
  end

  root :to => "static_pages#welcome"
  get "welcome" => "static_pages#welcome"
  get "about" => "static_pages#about"
  get "access_denied" => "static_pages#access_denied"

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks",
                                       :registrations => "registrations" }

  get "users/settings" => "users#edit"
  put "users/update" => "users#update"

  match "admins" => "admins#access_control"
  match "users" => "users#show"
  delete "admins/stop_masquerades" => "masquerades#destroy", as: :destroy_masquerades

  resources :users do
    resources :masquerades, only: [:new]
    collection do
      get 'search'
    end
  end
  #match "admins/index" =>"admins#index"
  get "lecturers/request" => "role_requests#new"
  resources :role_requests

  resources :courses do
    match "/submissions" => "submissions#listall", as: :submissions
    match "/training_submissions" => "training_submissions#listall", as: :training_submissions

    match "/leaderboards"     => "leaderboards#show", as: :leaderboards
    match "/stuff"            => "user_courses#stuff", as: :stuff
    match "/manage_students"  => "course_groups#manage_students", as: :manage_students
    post  "/add_student"      => "course_groups#add_student", as: :manage_add_student
    post "/update_exp"        => "course_groups#update_exp", as: :manage_update_exp

    resources :user_courses

    resources :missions do
      resources :questions
      resources :submissions do
        resources :submission_gradings
      end
    end

    resources :trainings do
      resources :mcqs
      resources :coding_questions
      resources :training_submissions
      post "training_submissions/:id/submit" => "training_submissions#submit", as: :training_submission_submit
    end

    resources :quizzes do
      resources :mcqs
      resources :quiz_submissions do
        resources :submission_gradings
      end
    end

    resources :mcq_answers

    resources :announcements

    post "levels/populate" => "levels#populate", as: :levels_populate

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

    resources :comments

    get "stats" => "stats#general"

    get "stats/missions/:mission_id" => "stats#mission", as: :stats_mission

    get "stats/trainings/:training_id" => "stats#training", as: :stats_training

    get "duplicate" => "duplicate#manage", as: :duplicate

    get "duplicate_course" => "duplicate#duplicate_course", as: :duplicate_course

    get "duplicate_assignments" => "duplicate#duplicate_assignments", as: :duplicate_assignments

    match "award_exp" => "manual_rewards#manual_exp", as: :manual_exp

    match "award_achievement" => "manual_rewards#manual_achievement", as: :manual_achievement

  end

  match "courses/:id/students" => "courses#students", as: :course_students

  resources :file_uploads
end
