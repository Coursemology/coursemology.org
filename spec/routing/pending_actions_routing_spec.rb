require "spec_helper"

describe PendingActionsController do
  describe "routing" do

    it "routes to #index" do
      get("/pending_actions").should route_to("pending_actions#index")
    end

    it "routes to #new" do
      get("/pending_actions/new").should route_to("pending_actions#new")
    end

    it "routes to #show" do
      get("/pending_actions/1").should route_to("pending_actions#show", :id => "1")
    end

    it "routes to #edit" do
      get("/pending_actions/1/edit").should route_to("pending_actions#edit", :id => "1")
    end

    it "routes to #create" do
      post("/pending_actions").should route_to("pending_actions#create")
    end

    it "routes to #update" do
      put("/pending_actions/1").should route_to("pending_actions#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/pending_actions/1").should route_to("pending_actions#destroy", :id => "1")
    end

  end
end
