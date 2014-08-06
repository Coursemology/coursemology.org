require 'spec_helper'

describe Assessment::McqQuestion do
  # it "checks mission default scope" do
  #   m = Assessment::Training.create! ({open_at: Time.now - 7.days, bonus_cutoff_at: Time.now})
  #   Assessment::Training.all
  #   m.destroy
  # end

  it "checks all mcq question associations by reflection" do
    m = Assessment::McqQuestion.create
    Assessment::McqQuestion.reflect_on_all_associations.each do |ast|
      m.send(ast.name)
    end
    m.destroy
  end
end
