require 'factory_girl'

FactoryGirl.define do
  factory :user do |f|
    f.sequence(:email) { |n| "foo#{n}@example.com" }
    f.password "secret"
    endclass
    # To change this template use File | Settings | File Templates.
  end

end