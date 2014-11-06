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

end
