require 'rails_helper'

feature 'LessonPlan', :type => :feature do
  # TODO: user should be lecturer instead of admin
  let(:user) { FactoryGirl.create(:admin) }
  let(:course) { FactoryGirl.create(:course) }
  let(:entry) { FactoryGirl.create(:lesson_plan_entry) }

  before do
    sign_in user
    create_course course
  end

  feature 'Create LessonPlanEntry' do
    before do
      visit new_course_lesson_plan_entry_path(course)

      select LessonPlanEntry::ENTRY_TYPES[entry.entry_type].first, :from =>'Type'
      fill_in 'Title', :with => entry.title
      fill_in 'Location', :with => entry.location
      fill_in 'Description/Objectives', :with => entry.description
      fill_in 'Start at', :with => entry.start_at
      fill_in 'End at', :with => entry.end_at
    end

    it 'increases the number of entries by 1' do
      expect { click_button 'Submit' }.to change(LessonPlanEntry, :count).by 1

    end

    it 'shows a created notice' do
      click_button 'Submit'
      expect(page).to have_text entry.title
    end
  end

  feature 'Edit LessonPlanEntry' do
    let(:entry) { FactoryGirl.build :lesson_plan_entry, course: course, creator: user }
    before do
      entry.save
      visit edit_course_lesson_plan_entry_path(course, entry)
    end

    it 'displays the editing page' do
      expect(page).to have_text 'Edit Lesson Plan Entry'
    end

    it 'contains fields for user to edit' do
      expect(page).to have_select 'Type'
      expect(page).to have_field 'Title'
      expect(page).to have_field 'Location'
      expect(page).to have_field 'Description/Objectives'
      expect(page).to have_field 'Start at'
      expect(page).to have_field 'End at'
    end

    feature 'updating of lesson plan entry' do
      let(:new_title) { 'New Title' }
      let(:new_description) { 'New description' }
      before do
        fill_in 'Title', :with => new_title
        fill_in 'Description/Objectives', :with => new_description
        click_button 'Submit'
      end

      it 'shows the success notice' do
        expect(page).to have_content "#{new_title} has been updated"
      end

      it 'updates the attributes of the entry' do
        entry.reload.title.should eq new_title
        entry.reload.description.should eq new_description
      end
    end
  end
end

