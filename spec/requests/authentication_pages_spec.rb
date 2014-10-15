require 'rails_helper'

describe "AuthenticationPages", :type => :feature do

  subject { page }

  describe "signin page" do
    before { visit new_user_session_path }

    it { should have_selector('h1', 'Sign in')}
    it { should have_button('Sign in') }

  end


  describe "sign in" do
    before { visit new_user_session_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector('h1', text: 'Sign in') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create( :lecturer ) }
      before do
        fill_in "Email",    with: user.email.upcase
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      it { should have_selector('h1', text: user.name) }

      it { should have_link('My Courses', href: my_courses_path) }
      it { should have_link('management') }
      it { should have_link('Sign out') }
      it { should_not have_link('Sign in', href: new_user_session_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end

  end

end
