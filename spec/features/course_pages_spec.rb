require 'rails_helper'

describe "CoursePages", :type => :feature do
  subject { page }

  let(:admin) { FactoryGirl.create(:admin) }
  before { sign_in admin }

  describe "course creation" do
    before do
      visit my_courses_path
      click_link "New Course"
    end

    # describe "with invalid information" do
    #   it "should not create a course" do
    #     expect { click_button "Create" }.not_to change(Course, :count)
    #   end
    # end

    describe "with valid information" do

      before do
        #print page.html
        fill_in 'course_title', with: "FirstCourse"
        fill_in 'course_description', with: "This is my first course"
      end
      it "should create a micropost" do
        expect { click_button "Create" }.to change(Course, :count).by(1)
      end
    end
  end
end
