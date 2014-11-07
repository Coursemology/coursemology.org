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
      it "should have New Mission button and Overview tab" do
        expect(page).to have_link('New Mission')
        expect(page).to have_content('Overview')
      end
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

        describe "new mission created" do
          before do
            click_button "Create Mission"
          end

          it "should have mission created text" do
            expect(page).to have_text("The mission Mission 0 has been created")
          end
        end
      end

    end


    describe "Mission Edit" do
      let(:title) { 'Factory mission' }
      let(:mission) {FactoryGirl.create(:mission, title: title, course: course)}

      # already opens the individual mission view
      it "should have factory mission" do
          visit course_assessment_mission_path(course, mission)
          expect(page).to have_text(title)
      end

      it "should have edit form labels" do
        visit edit_course_assessment_mission_path(course, mission)
        expect(page).to have_text('Title')
        expect(page).to have_text('Description')
      end

      it "should change mission title and description" do
        description = 'Some new mission description'

        visit edit_course_assessment_mission_path(course, mission)
        fill_in 'Title', with: 'Edited mission'
        fill_in 'Description', with: description
        click_button "Update Mission"

        expect(page).to have_text('The mission Edited mission has been updated')
        expect(page).to have_text(description)
      end

      it "should change mission experience" do
        exp = 1579
        
        visit edit_course_assessment_mission_path(course, mission)
        fill_in 'assessment_mission_exp', with: exp
        click_button "Update Mission"

        expect(page).to have_text(exp.to_s)
      end
    end



  end






end
