require 'spec_helper'

describe Assessment do
  # pending "add some examples to (or delete) #{__FILE__}"
  it "creates a mission" do
    m = Assessment::Mission.create! ({open_at: Time.now - 7.days, close_at: Time.now})
    m.destroy
  end

  it "creates a training" do
    m = Assessment::Training.create! ({open_at: Time.now - 7.days, bonus_cutoff_at: Time.now})
    m.destroy
  end

  m = Assessment::Mission.create! ({open_at: Time.now - 7.days, close_at: Time.now})

  it "checks requirements relationship" do
    m.as_requirements
  end

  it "checks questions relationship" do
    m.questions
  end

  it "checks tags relationship" do
    m.tags
  end

  it "checks queued jobs relationship" do
    m.queued_jobs
  end

  it "checks pending actions relationship" do
    m.pending_actions
  end

  it "checks files relationship" do
    m.files
  end

  m.destroy
end
