require 'spec_helper'

describe "tab/tabs/show" do
  before(:each) do
    @tab_tab = assign(:tab_tab, stub_model(Tab::Tab))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
