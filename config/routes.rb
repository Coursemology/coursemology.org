JfdiAcademy::Application.routes.draw do

  authenticated :user do
    root :to => "home#index"
  end

  root :to => "static_pages#welcome"
  get "welcome" => "static_pages#welcome"
  get "about" => "static_pages#about"
  get "access_denied" => "static_pages#access_denied"

  devise_for :users

  get "users/settings" => "users#edit"
  put "users/update" => "users#update"

  get "lecturers/request" => "role_requests#new"
  resources :role_requests

  resources :courses do
    match "/submissions" => "submissions#listall", as: :submissions
    match "/submissions/students/:student_id" => "submissions#listall", as: :submissions_student
    match "/quiz_submissions" => "quiz_submissions#listall", as: :quiz_submissions
    match "/quiz_submissions/students/:student_id" => "quiz_submissions#listall", as: :quiz_submissions_student
    match "/leaderboards" => "leaderboards#show", as: :leaderboards

    resources :user_courses

    resources :missions do
      resources :questions
      resources :submissions do
        resources :submission_gradings
      end
    end

    resources :trainings do
      resources :mcqs
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

    resources :file_uploads

    resources :enroll_requests

    resources :tags

    resources :asm_tags

    post "asm_tags/render_form_row" => "asm_tags#render_form_row"
  end

  match "courses/:id/students" => "courses#students", as: :course_students

  resources :file_uploads
end
