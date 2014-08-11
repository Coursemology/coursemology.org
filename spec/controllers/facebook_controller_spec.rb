require 'spec_helper'

describe FacebookController do

  describe "GET 'obtain_badge'" do
    it "returns http success" do
      get 'obtain_badge'
      response.should be_success
    end
  end

end
