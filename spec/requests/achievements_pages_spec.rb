require 'rails_helper'

RSpec.describe "Achievements", :type => :request do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:course) { FactoryGirl.create(:course) }
  before do
    sign_in admin
    create_course course
  end

  describe "create" do
    before do
      visit course_achievements_path(course)
    end

    it "shows the new button" do
      expect(page).to have_link('New', href: new_course_achievement_path(course))
    end

    describe "action" do
      before do
        click_link 'New'
      end

      it "displays the content" do
        expect(page).to have_field("Title")
        expect(page).to have_field("Description")
      end

      describe "add valid information" do
        let(:achievement) { FactoryGirl.build(:achievement) }
        before do
          fill_in 'Title', with: achievement.title
          fill_in 'Description', with: achievement.description
        end

        it "should create an achievement" do
          expect { click_button 'Create Achievement' }.to change(Achievement, :count).by(1)
        end

        describe "after achievement is created" do
          before do
            click_button 'Create'
          end

          it "displays that the achievement is created" do
            expect(page).to have_content(achievement.title)
          end
        end
      end
    end
  end


end
