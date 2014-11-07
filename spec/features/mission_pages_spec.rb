require 'rails_helper'

describe "MissionPages", :type => :feature do

  describe "Mission admin pages" do
    let(:lecturer) {FactoryGirl.create(:lecturer)}
    let!(:course) { FactoryGirl.create(:course, creator: lecturer) }
    before do
      sign_in lecturer
      click_link "Missions"
    end

    describe "mission display" do
      it "has New Mission button and Overview tab" do
        expect(page).to have_link('New Mission')
        expect(page).to have_content('Overview')
      end
    end

    describe "mission creation" do
      before do
        click_link "New Mission"
      end

      describe "with invalid information" do
        it "does not create a mission" do
          expect { click_button "Create Mission" }.not_to change(Assessment, :count)
        end

        describe "error messages" do
          before { click_button "Create Mission" }
          it "shows error messages" do
            pending "to be implemented"
            expect(page).to have_content('error')
          end
        end
      end

      describe "with valid information" do
        before do
          fill_in 'Title', with: "Mission 0"
          fill_in 'Description', with: 'This is the first mission'
        end

        it "creates a mission" do
          expect { click_button "Create Mission" }.to change(Assessment, :count).by(1)
        end

        describe "new mission created" do
          before do
            click_button "Create Mission"
          end

          it "has mission created text" do
            expect(page).to have_text("The mission Mission 0 has been created")
          end
        end
      end
    end

    describe "Single mission view" do
      let(:mission) {FactoryGirl.create(:mission, course: course)}
      before { visit course_assessment_mission_path(course, mission) }

      # already opens the individual mission view
      it "has factory mission" do
        expect(page).to have_text('Factory mission')
      end
    end

    describe "Mission Edit" do
      let(:mission) {FactoryGirl.create(:mission, course: course)}

      before do
        visit edit_course_assessment_mission_path(course, mission)
      end

      it "has edit form labels" do
        expect(page).to have_text('Title')
        expect(page).to have_text('Description')
      end

      context "with valid information" do
        let(:description) { 'Some new mission description' }
        let(:exp) { 1579 }

        before do
          fill_in 'Title', with: 'Edited mission'
          fill_in 'Description', with: description
          fill_in 'assessment_mission_exp', with: exp
          click_button "Update Mission"
        end

        it "changes mission title" do
          expect(page).to have_text('The mission Edited mission has been updated')
        end

        it "changes description" do
          expect(page).to have_text(description)
        end

        it "changes experience" do
          expect(page).to have_text(exp.to_s)
        end
      end

      context "with invalid information" do
        before do
          fill_in 'Title', with: ''
          fill_in 'Description', with: ''
        end

        it "stays on Edit Mission page" do
          expect(page).to have_text('Edit Mission')
        end
      end

    end
  end

end
