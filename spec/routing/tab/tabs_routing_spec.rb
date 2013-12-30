require "spec_helper"

describe Tab::TabsController do
  describe "routing" do

    it "routes to #index" do
      get("/tab/tabs").should route_to("tab/tabs#index")
    end

    it "routes to #new" do
      get("/tab/tabs/new").should route_to("tab/tabs#new")
    end

    it "routes to #show" do
      get("/tab/tabs/1").should route_to("tab/tabs#show", :id => "1")
    end

    it "routes to #edit" do
      get("/tab/tabs/1/edit").should route_to("tab/tabs#edit", :id => "1")
    end

    it "routes to #create" do
      post("/tab/tabs").should route_to("tab/tabs#create")
    end

    it "routes to #update" do
      put("/tab/tabs/1").should route_to("tab/tabs#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/tab/tabs/1").should route_to("tab/tabs#destroy", :id => "1")
    end

  end
end
