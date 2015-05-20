require 'rails_helper'

describe 'Course specific name', type: :feature do
  let!(:lecturer)           { FactoryGirl.create(:lecturer) }
  let!(:student)            { FactoryGirl.create(:student) }
  let!(:course)             { FactoryGirl.create(:course, :with_student, creator: lecturer, student: student) }
  let!(:user_course)        { student.get_user_course(course) }

  context 'when name change is allowed' do
    before { Course.any_instance.stub(:allow_name_change?).and_return(true) }

    context 'when change name in user profile' do
      let(:new_name) { 'New Name' }

      before do
        sign_in student
        visit users_settings_path
        fill_in 'user_name', with: new_name
        click_button 'Update'
      end

      it 'changes name in course' do
        expect(user_course.reload.name).to eq new_name
      end
    end

    context 'when change name in course' do
      let(:new_name) { 'New Name' }

      before do
        sign_in lecturer
        visit course_manage_students_path(course)
        fill_in 'name', with: new_name
        find(:xpath, '//button[@type="submit"]').click
      end

      it 'changes name in course' do
        expect(user_course.reload.name).to eq new_name
      end
    end
  end

  context 'when name change is not allowed' do
    before { Course.any_instance.stub(:allow_name_change?).and_return(false) }

    context 'when change name in user profile' do
      let(:new_name) { 'New Name' }

      before do
        sign_in student
        visit users_settings_path
        fill_in 'user_name', with: new_name
        click_button 'Update'
      end

      it 'does not change name in course' do
        expect(user_course.reload.name).not_to eq new_name
      end
    end

    context 'when change name in course' do
      let(:new_name) { 'New Name' }

      before do
        sign_in lecturer
        visit course_manage_students_path(course)
        fill_in 'name', with: new_name
        find(:xpath, '//button[@type="submit"]').click
      end

      it 'changes name in course' do
        expect(user_course.reload.name).to eq new_name
      end
    end
  end
end
