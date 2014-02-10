require 'spec_helper'

describe "pending_actions/index" do
  before(:each) do
    assign(:pending_actions, [
      stub_model(PendingAction),
      stub_model(PendingAction)
    ])
  end

  it "renders a list of pending_actions" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
