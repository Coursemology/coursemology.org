require 'spec_helper'

describe "PendingActions" do
  describe "GET /pending_actions" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get pending_actions_path
      response.status.should be(200)
    end
  end
end
