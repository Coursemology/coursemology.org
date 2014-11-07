RSpec.configure do |config|

 config.before(:suite) do
  DatabaseCleaner.clean_with(:truncation)
  load Rails.root + "db/seeds.rb" 
  # puts "before suite"
 end

 config.before(:each) do
  DatabaseCleaner.strategy = :transaction
  # puts "Before Normal"
 end

 config.before(:each, :js => true) do
 	Capybara.current_driver = :selenium_chrome
  DatabaseCleaner.strategy = :truncation
  # puts "Before JS"
 end

 config.before(:each) do
  DatabaseCleaner.start
  # puts "Before all"
 end

 config.after(:each, :js => true) do
  load Rails.root + "db/seeds.rb" 
  Capybara.use_default_driver 
  # puts "After JS"
 end

 config.after(:each) do
  DatabaseCleaner.clean
  # puts "After all"
 end

end
