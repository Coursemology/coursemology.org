require 'rails_helper'

RSpec.describe "Training", :type => :feature do

  subject { page }

  context "lecturer user" do
    let(:lecturer) { FactoryGirl.create(:lecturer) }
    let(:course) { FactoryGirl.create(:course, creator: lecturer) }
    let!(:training) { FactoryGirl.create(:training, course: course) }
    before do
      sign_in lecturer
    end

    describe "requests index page" do 
      before { click_link "Trainings" }
      it "has the overview tab" do
        is_expected.to have_content('Overview')
      end
    end

    describe "create" do
      before do
        click_link "Trainings"
        click_link "New Training"
      end

      context "with blank information" do
        it "does not create training" do
          expect { click_button 'Create Training' }.not_to change(Assessment, :count)
        end
      end

      context "with valid information" do
        before do
          fill_in 'Title', with: training.title
        end

        it "creates training" do
          expect { click_button 'Create Training' }.to change(Assessment, :count).by(1)
        end

        context "visiting training page" do
          before do
            visit course_assessment_training_path(course, training)
          end

          it "displays title" do
            expect(page).to have_text(training.title)
          end

          it "displays description" do
            expect(page).to have_text(training.description)
          end
        end
      end

    end

    describe "edit" do
      before do
        visit course_assessment_training_path(course, training)
        click_link "", href: edit_course_assessment_training_path(course, training)
      end

      describe "page" do
        it "is pre-filled" do
          expect(page).to have_selector("input[value='#{training.title}']")
        end
      end
      
      context "with valid information" do
        let(:new_title) { "New Title" }
        let(:new_desc) { "New Desc" }
        let(:new_exp) { 998 }
        before do
          fill_in "Title", with: new_title
          fill_in "Description", with: new_desc
          fill_in "Exp", with: new_exp
          click_button "Update Training"
        end

        it "redirects to training page" do
          expect(current_path).to eq course_assessment_training_path(course, training)
        end

        it "shows the success notice" do
          expect(page).to have_content("The training '#{new_title}' has been updated.")
        end

        it "changes the title" do
          expect(training.reload.title).to eq new_title
        end

        it "changes the description" do
          expect(training.reload.description).to eq new_desc
        end

        it "changes the exp points" do
          expect(training.reload.exp).to eq new_exp
        end
      end

      context "with invalid information" do
        let(:new_title) { '' }
        let(:new_exp) { 'exp' }
        before do
          fill_in "Title", with: new_title
          fill_in "Exp", with: new_exp
          click_button "Update Training"
        end

        it "does not redirect" do
          expect(page).to have_css("div.error")
        end
      end
    end

    describe "destroy" do
      before do
        visit course_assessment_training_path(course, training)
      end

      it "deletes the training" do
        expect { find("a.btn-danger").click }.to change(Assessment, :count).by(-1)
      end
    end

  end
end


