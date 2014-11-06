require 'rails_helper'

RSpec.describe "AnnouncementPages", :type => :request, :js => true do

 let(:admin) {FactoryGirl.create(:admin)}
 let(:course) { FactoryGirl.create(:course) }
 before do
   Capybara.current_driver = :selenium_chrome
   sign_in admin
   create_course course
 end

 describe "Announcement Creation" do
   before do
     visit course_announcements_path(course)
   end

   # it "shows the new button" do
   #   expect(page).to have_link('New', href: new_course_announcement_path(course))
   # end

   describe "create action" do
     before do
       click_link 'New'
     end

     # it "displays the content"  do
     #   expect(page).to have_field("announcement_title")
     #   expect(page).to have_selector("iframe.wysihtml5-sandbox")
     # end

     describe "with valid information" do
       let(:announcement) {FactoryGirl.build(:announcement)}
       before do
         fill_in 'announcement_title', with: announcement.title
         #fill_in 'announcement_description', visible: false, with: announcement.description
         #find('#announcement_description').set(announcement.description)
         #find(:xpath, "iframe");

         page.execute_script("$('#announcement_description').attr('value','abcd');")

         # within_frame "iframe.wysihtml5-sandbox" do
         #   #fill_in 'body', with: announcement.description
         #   find(:xpath, "//body").text
         # end
       end

       it "should create an announcement"  do
         expect(page).to have_selector("textarea[value='abcd']", visible: false)
         expect { click_button 'Create'}.to change(Announcement, :count).by(1)

       end
     end
   end

 end

 after(:all) do
   Capybara.use_default_driver
 end

end