require 'spec_helper'

describe "tab/tabs/index" do
  before(:each) do
    assign(:tab_tabs, [
      stub_model(Tab::Tab),
      stub_model(Tab::Tab)
    ])
  end

  it "renders a list of tab/tabs" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
