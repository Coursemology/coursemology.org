require 'rails_helper'

RSpec.describe Course, type: :model do
  let!(:course) { FactoryGirl.create(:course) }

  describe '#allow_name_change?' do
    context 'when there is no preference' do
      before { Course.any_instance.stub(:user_course_change_name_pref).and_return(nil) }

      it 'returns true' do
        expect(course.allow_name_change?).to eq true
      end
    end

    context 'when disabled in preference' do
      before { course.user_course_change_name_pref.update_column(:display, false) }

      it 'returns false' do
        expect(course.allow_name_change?).to eq false
      end
    end

    context 'when enabled in preference' do
      before { course.user_course_change_name_pref.update_column(:display, true) }

      it 'returns true' do
        expect(course.allow_name_change?).to eq true
      end
    end
  end
end
