require 'rails_helper'

RSpec.describe 'Achievements', :type => :request do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:course) { FactoryGirl.create(:course) }
  before do
    sign_in admin
    create_course course
  end

  describe 'create' do
    before do
      visit course_achievements_path(course)
    end

    it 'shows the new button' do
      expect(page).to have_link('New', href: new_course_achievement_path(course))
    end

    describe 'action' do
      before do
        click_link 'New'
      end

      it 'displays the content' do
        expect(page).to have_field('Title')
        expect(page).to have_field('Description')
      end

      describe 'add valid information' do
        let(:achievement) { FactoryGirl.build(:achievement) }
        before do
          fill_in 'Title', with: achievement.title
          fill_in 'Description', with: achievement.description
        end

        it 'create an achievement' do
          pending 'to mock the facebook graph connect'
          expect { click_button 'Create Achievement' }.to change(Achievement, :count).by(1)
        end

        describe 'after achievement is created' do
          before do
            click_button 'Create'
          end

          it 'displays that the achievement is created' do
            expect(page).to have_content(achievement.title)
          end
        end
      end
    end
  end

  describe 'edit' do
    let!(:achievement) { FactoryGirl.create(:achievement, course: course) }
    before { visit course_achievements_path(course) }

    describe 'page' do
      it 'shows the edit button' do
        expect(page).to have_link('', href: edit_course_achievement_path(course, achievement))
      end


      describe 'when editing achievements' do
        before { visit edit_course_achievement_path(course, achievement) }

        it 'renders the view correctly' do
          expect(page).to have_field('Title')
          expect(page).to have_field('Description')
        end

        context 'with changes saved' do
          let(:new_title) { 'Edited Title' }
          let(:new_description) { 'Edited Description' }
          before do
            fill_in 'Title', with: new_title
            fill_in 'Description', with: new_description
            pending 'to be implemented after javascript is enabled'
            click_button 'Update'
          end

          it 'redirects back to index' do
            expect(current_path).to eq course_achievement_path(course)
          end

          it 'shows the successful notice' do
            expect(page).to have_content("The achievement '#{new_title}' has been updated.")
          end

          it 'shows changed attributes' do
            achievement.reload.title.should eq new_title
            achievement.reload.description.should eq new_description
          end
        end
      end
    end
  end

  describe 'delete' do
    let!(:achievement) { FactoryGirl.create(:achievement, course: course) }
    before do
      visit course_achievements_path(course)
    end

    describe 'page' do
      it 'shows the delete button' do
        expect(page).to have_link 'delete_achievement'
      end
    end

    describe 'action' do
      it 'deletes the achievement' do
        pending 'to mock the facebook graph connect'
        expect { click_link 'delete_achievement' }.to change(Achievement, :count).by(-1)
      end
    end

    it 'redirects back to index' do
      expect(current_path).to eq course_achievements_path(course)
    end
  end

end
