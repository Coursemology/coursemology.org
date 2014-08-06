require 'factory_girl'

FactoryGirl.define do
  factory :admin, class: User do
    name "admin"
    email "admin@test.com"
    password "foobar"
    password_confirmation "foobar"
    after(:build) do |user|
      user.system_role_id = 1
      user.confirmed_at = Time.now.to_s[0..-7]
    end
  end

  factory :student, class: User do
    name "student"
    email "student@test.com"
    password "foobar"
    password_confirmation "foobar"
    after(:build) do |user|
      user.system_role_id = 5
      user.confirmed_at = Time.now.to_s[0..-7]
    end
  end


  factory :lecturer, class: User do
    name "lecturer"
    email "lecturer@test.com"
    password "foobar"
    password_confirmation "foobar"
    after(:build) do |user|
      user.system_role_id = 3
      user.confirmed_at = Time.now.to_s[0..-7]
    end
  end

end