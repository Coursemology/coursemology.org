require 'rails_helper'

RSpec.describe "AnnouncementPages", :type => :request do

  let(:admin) {FactoryGirl.create(:admin)}
  let(:course) { FactoryGirl.create(:course) }
  before do
    sign_in admin
    create_course course
  end

  describe "Announcement Creation", :js => true do
    before do
      visit course_announcements_path(course)
    end

    describe "Test 1" do
      it "shows the new button" do
        expect(page).to have_link('New', href: new_course_announcement_path(course))
      end
    end

    describe "create action" do
      before do
        click_link 'New'
      end

      it "displays the content"  do
        expect(page).to have_field("announcement_title")
        expect(page).to have_selector("iframe.wysihtml5-sandbox")
      end

      describe "with valid information" do
        let(:announcement) {FactoryGirl.build(:announcement)}
        before do
          fill_in 'announcement_title', with: announcement.title
          page.execute_script("$('#announcement_description').attr('value','abcd');")
        end

        it "should create an announcement", :js => true  do
          expect(page).to have_selector("textarea[value='abcd']", visible: false)
          expect { click_button 'Create'}.to change(Announcement, :count).by(1)
        end
      end
    end
  end
end
