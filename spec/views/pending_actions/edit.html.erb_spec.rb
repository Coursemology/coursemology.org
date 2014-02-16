require 'spec_helper'

describe "pending_actions/edit" do
  before(:each) do
    @pending_action = assign(:pending_action, stub_model(PendingAction))
  end

  it "renders the edit pending_action form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", pending_action_path(@pending_action), "post" do
    end
  end
end
