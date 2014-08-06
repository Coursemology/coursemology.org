require 'spec_helper'

describe "pending_actions/new" do
  before(:each) do
    assign(:pending_action, stub_model(PendingAction).as_new_record)
  end

  it "renders new pending_action form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", pending_actions_path, "post" do
    end
  end
end
