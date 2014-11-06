require 'rails_helper'

RSpec.describe "AnnouncementPages", :type => :feature do
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

    describe 'edit page' do
      before { visit edit_course_announcement_path(course, announcement) }

      it 'renders the view correctly' do
        expect(page).to have_field('Title')
        expect(page).to have_field('Description')
        expect(page).to have_content('Publish at')
        expect(page).to have_button('Update')
      end

      context 'after changes saved' do
        let(:new_title)  { 'New Title' }
        let(:new_content) { 'new content' }
        before do
          fill_in 'Title',    with: new_title
          fill_in 'Description',    with: new_content
          click_button 'Update'
        end

        it 'should redirect back to index' do
          expect(current_path).to eq course_announcements_path(course)
        end

        it 'should show the success notice' do
          expect(page).to have_content("'#{new_title}' has been updated")
        end

        it 'attributes should be changed' do
          announcement.reload.title.should eq new_title
          announcement.reload.description.should eq new_content
        end
      end
    end
  end

end
