#!/usr/bin/env ruby
require 'clockwork'
require_relative '../config/boot'
require_relative '../config/environment'

module Clockwork
  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end
  handler do |job|
    Delayed::Job.enqueue job
    puts "Running #{job}"
  end

  # List all other jobs here
  every(1.day, MailingJob.new(nil, 'ForumDigests', nil, nil), at: '00:00')
end
