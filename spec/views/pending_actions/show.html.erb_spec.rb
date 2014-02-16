require 'spec_helper'

describe "pending_actions/show" do
  before(:each) do
    @pending_action = assign(:pending_action, stub_model(PendingAction))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
