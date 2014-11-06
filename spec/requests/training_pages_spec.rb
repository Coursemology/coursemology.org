require 'rails_helper'

RSpec.describe "TrainingPages", :type => :request do

	subject { page }
  let(:course) { FactoryGirl.create(:course) }
  let(:training) { FactoryGirl.create(:training) }

  context "for Admin" do
  	let(:admin) { FactoryGirl.create(:admin) }
    before do
      sign_in admin
      create_course course
      click_link "Trainings"
    end

	  it "has the overview tab" do
	    is_expected.to have_content('Overview')
	  end

	  describe "creating" do
		  before do
	      click_link "New Training"
	    end

	    describe "with blank information" do
			  it "should not create training" do
			  	expect { click_button "Create Training" }.to change(Assessment, :count).by(0)
			  end
	    end

	    describe "with valid information" do
		    before do
		    	fill_in 'Title', with: training.title
			  end
				it "should create training" do
			  	expect { click_button "Create Training" }.to change(Assessment, :count).by(1)
			  end		  
	    end
	  end
  end
end


