require 'spec_helper'

describe Course do
  it "checks all associations by reflection" do
    c = Course.first
    Course.reflect_on_all_associations.each do |asc|
      c.send(asc.name)
    end
  end
end