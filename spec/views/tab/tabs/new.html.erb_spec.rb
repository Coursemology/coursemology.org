require 'spec_helper'

describe "tab/tabs/new" do
  before(:each) do
    assign(:tab_tab, stub_model(Tab::Tab).as_new_record)
  end

  it "renders new tab_tab form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", tab_tabs_path, "post" do
    end
  end
end
