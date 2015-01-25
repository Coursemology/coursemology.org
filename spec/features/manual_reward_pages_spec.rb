require 'rails_helper'

RSpec.describe "ManualRewardPages", :type => :feature do
  let(:user) { FactoryGirl.create(:lecturer) }
  let(:student) { FactoryGirl.create(:student) }
  let!(:course) { FactoryGirl.create(:course, creator: user) }
  let!(:user_course) { FactoryGirl.create(:user_course, user: student, course: course) }

  before do
    sign_in user
  end

  describe "manual_exp page" do
    before do
      visit course_manual_exp_path(course)
      expect(page).to have_link('View all students')
      click_link('View all students')
    end

    it "shows student" do
      expect(page).to have_content(student.name)
    end
    it "adds exp to student" do
      find(:xpath, "//input[@name=\"exps[#{user_course.id}]\"]").set(100)
      expect { click_button 'Give EXP' }.to change(ExpTransaction, :count).by(1)
    end
  end

end
