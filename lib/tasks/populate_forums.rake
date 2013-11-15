namespace :db do
  desc 'Populate forums for all existing courses'

  task populate_forums: :environment do
    Course.all.each do |cs|
      cs.populate_forum
    end
  end
end