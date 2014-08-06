require 'rspec'

describe 'Authentication' do

  subject { page }

  describe "signin page", :type=> :feature do
    before { visit new_user_session_path }

    it {  should have_selector('h1', text:"Sign in") }
    #it {  should have_selector('title', text:"Sign in") }
  end

  describe "signin", :type=>:feature do
    before {visit new_user_session_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it {  should have_selector('h1',text:'Sign in') }
      it {  should have_selector('div.alert.alert-error',text:'Invalid email or password.') }
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email",        with:user.email
        fill_in "Password",     with:user.password
        click_button  "Sign in"
      end

      #TODO
      #it {   should have_link('Sign out',href:destroy_user_session_path)  }
    end

  end
end