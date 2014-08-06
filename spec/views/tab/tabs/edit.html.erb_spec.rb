require 'spec_helper'

describe "tab/tabs/edit" do
  before(:each) do
    @tab_tab = assign(:tab_tab, stub_model(Tab::Tab))
  end

  it "renders the edit tab_tab form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", tab_tab_path(@tab_tab), "post" do
    end
  end
end
