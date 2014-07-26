require 'spec_helper'

describe Assessment::Submission do
  # it "checks mission default scope" do
  #   m = Assessment::Training.create! ({open_at: Time.now - 7.days, bonus_cutoff_at: Time.now})
  #   Assessment::Training.all
  #   m.destroy
  # end

  it "checks all answer grading associations by reflection" do
    m = Assessment::Submission.create!
    Assessment::Submission.reflect_on_all_associations.each do |ast|
      m.send(ast.name)
    end
    m.destroy
  end
end