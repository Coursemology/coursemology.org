require 'factory_girl'

FactoryGirl.define do
  factory :user do
    name "user"
    email "user@test.com"
    password "foobar"
    password_confirmation "foobar"
    after(:build) do |user|
      user.confirmed_at = Time.now.to_s[0..-7]
    end
  end

  factory :admin, parent: :user do
    name "admin"
    email "admin@example.org"
    after(:build) do |user|
      user.system_role_id = 1
      #user.confirmed_at = Time.now.to_s[0..-7]
    end
  end

  factory :student, parent: :user do
    name "student"
    email "student@example.org"
    after(:build) do |user|
      user.system_role_id = 5
    end
  end


  factory :lecturer, parent: :user do
    name "lecturer"
    email "lecturer@example.org"
    after(:build) do |user|
      user.system_role_id = 3
    end
  end


  factory :course do
    title "Programming"
    description "It's a programming course"
    start_at Time.now
    end_at 1.day.from_now
    after(:create) do |course, evaluator|
      if evaluator.creator
        course.creator = evaluator.creator
        user_course = course.user_courses.build()
        user_course.course = course
        user_course.user = evaluator.creator
        user_course.role = Role.find_by_name(:lecturer)
        user_course.save
      end
    end
  end

  factory :training, class: Assessment::Training do
    title "Danger Room"
    description "Fight sentinels."
    exp 200
    open_at Time.now
    bonus_cutoff_at Time.now

    after(:build) do |training, evaluator|
      training.course_id = evaluator.course.try(:id)
    end
  end

  factory :announcement do
    title "sample announcement"
    description "sample content"
    publish_at Time.now
    expiry_at 3.day.from_now
    after(:build) do |announcement, evaluator|
      announcement.course_id = evaluator.course.try(:id)
      announcement.creator_id = evaluator.creator.try(:id)
      announcement.expiry_at = evaluator.expiry_at if evaluator.expiry_at
    end
  end

  factory :lesson_plan_entry do
    entry_type 0
    title 'My Lecture'
    location 'LT26'
    description 'Teaching an awesome class. How cool is that?'
    start_at 1.day.from_now
    end_at 3.days.from_now
  end

  factory :mission, class: Assessment::Mission do
    title 'Factory mission'
    open_at Time.now
    close_at 1.day.from_now
    exp 10
    after(:build) do |mission, evaluator|
      mission.title = evaluator.title
      mission.course_id = evaluator.course.try(:id)
    end
  end
  
  factory :achievement do
    title "I won!"
    description "Yahoo"
    after(:build) do |achievement, evaluator|
      achievement.course_id = evaluator.course.try(:id)
      achievement.creator_id = evaluator.creator.try(:id)
    end
  end

end
