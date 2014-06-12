require 'spec_helper'

describe Assessment::Mission do
  it "checks mission default scope" do
    m = Assessment::Mission.create! ({open_at: Time.now - 7.days, close_at: Time.now})
    Assessment::Mission.all
    m.destroy
  end

  it "checks all associations by reflection" do
    m = Assessment::Mission.create! ({open_at: Time.now - 7.days, close_at: Time.now})
    Assessment::Mission.reflect_on_all_associations.each do |ast|
      m.send(ast.name)
    end
    m.destroy
  end
end
