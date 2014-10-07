require 'rails_helper'

describe "MissionPages", :type => :feature do

  describe "Mission admin pages" do

    subject { page }
    let(:admin) {FactoryGirl.create(:admin)}
    let(:course) { FactoryGirl.create(:course) }
    before do
      sign_in admin
      create_course course
      click_link "Missions"
    end

    describe "mission display" do
      it {should have_link('New Mission')}
      it {should have_content('Overview')}
    end

    describe "mission creation" do
      before do
        click_link "New Mission"
        #save_and_open_page
      end

      describe "with invalid information" do

        it "should not create a mission" do
          expect { click_button "Create Mission" }.not_to change(Assessment, :count)
        end
        #
        # describe "error messages" do
        #   before { click_link "Create Mission" }
        #   it { should have_content('error') }
        # end
      end

      describe "with valid information" do
        before do
          fill_in 'Title', with: "Mission 0"
          fill_in 'Description', with: 'This is the first mission'
        end

        it "should create a mission" do
          expect { click_button "Create Mission" }.to change(Assessment, :count).by(1)
        end
      end

    end
  end






end
