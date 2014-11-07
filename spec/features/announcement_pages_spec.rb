require 'rails_helper'

RSpec.describe "AnnouncementPages", :type => :feature do
  let(:user) { FactoryGirl.create(:lecturer) }
  let!(:course) { FactoryGirl.create(:course, creator: user) }

  before do
    sign_in user
  end

  describe "create" do
    before do
      visit new_course_announcement_path(course)
    end

    describe "page" do
      it "shows the content" do
        expect(page).to have_content("New Announcement")
      end
    end

    context "when information is valid" do
      let(:announcement) { FactoryGirl.build(:announcement) }

      before do
        fill_in "Title", with: announcement.title
        fill_in "Description", with: announcement.description
      end

      it "creates an announcement" do
        expect { click_button 'Create' }.to change(Announcement, :count).by(1)
      end

      describe "after announcement created" do
        before do
          click_button 'Create'
        end

        it "displays the announcement title" do
          expect(page).to have_content(announcement.title)
        end

        it "displays the announcement description" do
          expect(page).to have_content(announcement.description)
        end
      end
    end

    context "when information is not valid" do
      it "does not change announcement count" do
        pending "to be implemented"
        expect { click_button 'Create' }.not_to change(Announcement, :count)
      end
    end
  end

  describe "index page" do
    let!(:announcement) { FactoryGirl.create(:announcement, course: course, creator: user) }

    before do
      visit course_announcements_path(course)
    end

    it "shows the new button" do
      expect(page).to have_link('New', href: new_course_announcement_path(course))
    end

    it "shows the edit button" do
      expect(page).to have_link('', href: edit_course_announcement_path(course, announcement))
    end

    it "shows the delete button" do
      expect(page).to have_link('', href: course_announcement_path(course, announcement))
    end
  end

  describe "edit" do
    let!(:announcement) { FactoryGirl.create(:announcement, course: course, creator: user) }
    before { visit edit_course_announcement_path(course, announcement) }

    describe "page" do
      it "shows the title" do
        expect(page).to have_content('Edit Announcement')
      end
    end

    context "when information is valid" do
      let(:new_title)  { "New Title" }
      let(:new_content) { "new content" }

      before do
        fill_in "Title", with: new_title
        fill_in "Description", with: new_content
        click_button "Update"
      end

      it "redirects back to index" do
        expect(current_path).to eq course_announcements_path(course)
      end

      it "shows the success notice" do
        expect(page).to have_content("'#{new_title}' has been updated")
      end

      it "changes the title" do
        expect(announcement.reload.title).to eq new_title
      end

      it "changes the description" do
        expect(announcement.reload.description).to eq new_content
      end
    end

    context "when information is not valid" do
      before do
        fill_in "Title", with: ''
        fill_in "Description", with: ''
        click_button "Update"
      end

      it "shows the error" do
        pending "to be implemented, currently we are allowing empty announcement"
        expect(page).to have_content("error")
      end
    end
  end

  describe "destroy" do
    let!(:announcement) { FactoryGirl.create(:announcement, course: course, creator: user) }

    describe "as correct user" do
      before { visit course_announcements_path(course) }

      it "deletes an announcement" do
        expect { find("a.btn-danger").click }.to change(Announcement, :count).by(-1)
      end
    end
  end
end
