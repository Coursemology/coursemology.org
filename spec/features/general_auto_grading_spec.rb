require 'rails_helper'

describe "AutoGrading", type: :feature do
  describe "Mission admin pages" do
    let!(:lecturer) { FactoryGirl.create(:lecturer) }
    let!(:course) { FactoryGirl.create(:course, creator: lecturer) }
    before do
      sign_in lecturer
      visit new_course_assessment_submission_grading_path(course.id,
                                                          mission.assessment.id,
                                                          mission.submissions.first.id)
    end

    describe "exact options" do
      let!(:mission) do
        FactoryGirl.create(:mission, :with_auto_graded_exact_general_questions, :completed, course: course)
      end
      it 'should display the options' do
        expect(page).to have_text("Grading: #{mission.title}")
        expect(page).to have_selector('.auto-grading-exact', count: 2)
      end
    end

    describe "keyword options" do
      let!(:mission) do
        FactoryGirl.create(:mission, :with_auto_graded_keyword_general_questions, :completed, course: course)
      end
      it 'should display the options' do
        expect(page).to have_text("Grading: #{mission.title}")
        expect(page).to have_selector('.auto-grading-keyword', count: 2)
      end
    end
  end
end
