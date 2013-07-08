require 'spec_helper'

describe 'User pages' do

  subject { page }

  describe "profile page", :type =>:feature do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }
    #TODO
    #it { should have_selector('a', text: user.name) }
    #it { should have_selector('title', text: user.name) }
  end

  describe "signup", :type =>:feature do
    before { visit new_user_registration_path }

    let(:submit) { "Sign up" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid information", :type =>:feature do
      before do
        fill_in "Name",                     with:"Example User"
        fill_in "Email",                    with:"user@example.com"
        fill_in "Password",             with:"foobar"
        fill_in "Password confirmation",    with:"foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User,:count).by(1)
      end
      it
    end
  end

end