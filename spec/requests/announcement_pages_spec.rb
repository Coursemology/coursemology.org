require 'rails_helper'

RSpec.describe "AnnouncementPages" do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:course) { FactoryGirl.create(:course) }
  before do
    sign_in admin
    create_course course
  end

  describe "creation" do
    before do
      visit course_announcements_path(course)
    end
    it "shows the new button" do
      expect(page).to have_link('New', href: new_course_announcement_path(course))
    end

    describe "create action" do
      before do
        click_link 'New'
      end

      it "displays the content" do
        expect(page).to have_field("Title")
        expect(page).to have_field("Description")
      end

      describe "with valid information" do
        let(:announcement) { FactoryGirl.build(:announcement) }
        before do
          fill_in 'Title', with: announcement.title
          fill_in 'Description', with: announcement.description
        end

        it "should create an announcement" do
          expect { click_button 'Create' }.to change(Announcement, :count).by(1)
        end

        describe "after announcement created" do
          before do
            click_button 'Create'
          end
          it "displays the announcement just created" do
            expect(page).to have_content(announcement.title)
            expect(page).to have_content(announcement.description)
          end
        end
      end
    end
  end

  describe "editing" do
    let(:announcement) { FactoryGirl.build(:announcement, course: course, creator: admin) }
    before do
      announcement.save
      visit course_announcements_path(course)
    end

    describe "page display" do
      it "shows the edit button" do
        expect(page).to have_link('', href: edit_course_announcement_path(course, announcement))
      end
    end
  end

end
