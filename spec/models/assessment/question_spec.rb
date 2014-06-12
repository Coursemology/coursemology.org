require 'spec_helper'

describe Assessment::Question do
  # it "creates a question" do
  #   m = Assessment::Mission.create! ({open_at: Time.now - 7.days, close_at: Time.now})
  #   Assessment::Mission.all
  #   m.destroy
  # end

  it "checks all question associations by reflection" do
    m = Assessment::Question.create!
    Assessment::Question.reflect_on_all_associations.each do |ast|
      m.send(ast.name)
    end
    m.destroy
  end
end
