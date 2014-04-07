JfdiAcademy::Application.routes.draw do

  authenticated :user do
    root :to => "home#index"
  end

  root :to => "static_pages#welcome"
  get "welcome" => "static_pages#welcome"
  get "about" => "static_pages#about"
  get "privacy_policy" => "static_pages#privacy_policy"
  get "access_denied" => "static_pages#access_denied"
  get "contact_us" => "static_pages#contact_us"
  get "help" => "static_pages#help"

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks",
                                       :registrations => "registrations",
                                       :sessions => "sessions"}

  get "users/settings" => "users#edit"
  put "users/update" => "users#update"

  post "user/auto_login" => "auto_login#auto_login_from_facebook"


  match "admins" => "admins#access_control"
  match "admins/search" => "admins#search"
  match "admins/masquerades" => 'admins#masquerades', as: :admin_masquerades
  match "admins/courses" => "admins#courses", as: :admin_courses
  #match "admin/access_control" => "admins#access_control"

  delete "admins/stop_masquerades" => "masquerades#destroy", as: :destroy_masquerades
  get "/my_courses" => "home#my_courses", as: :my_courses

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
    post "/remove_staff/:id"            => "user_courses#remove_staff", as: :remove_staff
    match "/manage_group"  => "course_groups#manage_group", as: :manage_group
    post  "/add_student"      => "course_groups#add_student", as: :manage_add_student
    post  "/update_exp"        => "course_groups#update_exp", as: :manage_update_exp
    match "missions/overview" => "missions#overview", as: :missions_overview
    post  "missions/bulk_update" => "missions#bulk_update", as: :missions_bulk_update
    match "trainings/overview" => "trainings#overview", as: :trainings_overview
    post "trainings/duplicate_qn" => "trainings#duplicate_qn", as: :trainings_duplicate_qn
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
      post "submissions/:id/test" => "submissions#test_answer", as: :submission_test

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
    get "pending_actions/:id/ignore" => "pending_actions#ignore", as: :pending_actions_ignore

    resources :mcq_answers

    resources :announcements

    get "materials", to: "materials#index"
    resources :material_virtual_folders, only: [], path: "materials/virtuals", controller: "materials" do
      get "index", :on => :member, :to => "materials#index_virtual"
    end
    resources :material_folders, only: [], path: "materials/folders", controller: "materials" do
      post "create", :on => :collection, to: "materials#create"
      member do
        get "show", to: "materials#index"
        get "edit", to: "materials#edit_folder"
        get "upload", to: "materials#new"
        post "create", to: "materials#create"
        put "update", to: "materials#update_folder"
        delete "", to: "materials#destroy_folder"
      end

      get "mark_read", to: "materials#mark_folder_read"
    end
    resources :material_files, except: [:index, :create], path: "materials/files", controller: "materials"
    get "materials/files/:id", to: "materials#show", as: :material # Alias for url_for with Material objects
    get "materials/*path", to: "materials#show_by_name", as: :material_by_path

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

    match "duplicate_assignments" => "duplicate#duplicate_assignments", as: :duplicate_assignments

    match "award_exp" => "manual_rewards#manual_exp", as: :manual_exp

    match "award_achievement" => "manual_rewards#manual_achievement", as: :manual_achievement

    match "remove_achievement" => "manual_rewards#remove_achievement", as: :remove_achievement

    get "preferences" => "course_preferences#edit", as: :preferences

    post "preferences" => "course_preferences#update", as: :preferences

    resources :mass_enrollment_emails

    post "send_enrollment_emails" => "mass_enrollment_emails#send_enroll_emails"
    match "resend_enrollment_emails" => "mass_enrollment_emails#resend_emails"
    match "delete_enrollment_invitations" => "mass_enrollment_emails#delete_mass"

    #resources :student_summary

    get "student_summary" => "student_summary#index"
    get "/student_summary/export" => "student_summary#export", as: :student_summary_export

    resources :staff_leaderboard

    resources :surveys do
      resources :survey_sections do
        collection do
          post 'reorder'
        end
      end
      resources :survey_questions, only: [:new, :create, :edit, :update, :destroy] do
        collection do
          post 'reorder'
        end
      end
      resources :survey_submissions
      post "survey_submissions/:id/submit" => "survey_submissions#submit", as: :survey_submission_submit
    end

    match "surveys/:id/stats" => "surveys#stats", as: :survey_stats
    match "surveys/:id/summary" => "surveys#summary", as: :survey_summary
    match "surveys/:id/summary_with_format" => "surveys#summary_with_format", as: :survey_summary_with_format

    get "lesson_plan" => 'lesson_plan_entries#index', as: :lesson_plan
    get "lesson_plan/overview" => 'lesson_plan_entries#overview', as: :lesson_plan_overview
    post "lesson_plan/bulk_update" => 'lesson_plan_milestones#bulk_update', as: :lesson_plan_bulk_update
    resources :lesson_plan_entries, path: 'lesson_plan/entries', except: [:index, :show]
    resources :lesson_plan_milestones, path: 'lesson_plan/milestones', except: [:index]

    get "staff_monitoring" => "staff_leaderboard#monitoring", as: :staff_monitoring

    resources :comics do
      member do
        post "create", to: "comics#create_page"
        get "info" => 'comics#info', as: :info
      end
      resources :comic_pages
    end


    resources :forums, module: :forums do
      resources :topics, except: [:index] do
        resources :posts, only: [:create, :edit, :update, :destroy] do
          put 'vote' => 'posts#set_vote'
          put 'answer' => 'posts#set_answer'
          get 'reply' => 'posts#reply', on: :member
        end

        get 'subscribe' => 'topics#subscribe', on: :member
        get 'unsubscribe' => 'topics#unsubscribe', on: :member
        put 'hide' => 'topics#set_hide'
        put 'lock' => 'topics#set_lock'
        put 'type' => 'topics#set_type'
      end

      get 'subscribe' => 'forums#subscribe', on: :member
      get 'unsubscribe' => 'forums#unsubscribe', on: :member
      get 'toggle_lock'   => 'forums#toggle_lock', on: :member
      get 'mark_read' => 'forums#mark_read', on: :member
      get 'mark_read' => 'forums#mark_all_read', on: :collection
      get 'next_unread' => 'forums#next_unread', on: :collection
      get 'next_unanswered' => 'forums#next_unanswered', on: :collection
    end

    match "forum_participation" => "forum_participation#manage", as: :forum_participation
    match "forum_participation/user/:poster_id" => "forum_participation#individual", as: :forum_participation_individual

    resources :tabs, module: :tabs
  end

  match "courses/:id/students" => "courses#students", as: :course_students
  match "courses/:id/manage_students" => "courses#manage_students", as: :course_manage_students
  match "courses/:id//pending_gradings"   => "courses#pending_gradings", as: :course_pending_gradings

  resources :file_uploads

  match "file_uploads/:id/toggle_access" => "file_uploads#toggle_access", as: :file_uploads_toggle_access

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
