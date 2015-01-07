require 'rails_helper'

feature "ScribingQuestions", :type => :feature do
  let(:lecturer) {FactoryGirl.create(:lecturer)}
  let!(:course) { FactoryGirl.create(:course, creator: lecturer) }

  before do
    skip
    sign_in lecturer
    let(:title) { 'Factory mission' }
    let!(:mission) {FactoryGirl.create(:mission, title: title, course: course)}
  end

  scenario "Create basic scribing question" do
    visit new_course_assessment_assessment_scribing_question_path(course, mission)
    fill_in 'Title', with: 'Scribing question'
    fill_in 'Max Grade', with: 10
    fill_in 'Tags', with: 'tag1'
    click_button 'Create Scribing Question'

    expect(page).to have_text('Question has been added')
    expect(page).to have_text('SCRIBING QUESTION')
  end
end
