namespace :db do
  desc 'Make forums for all existing courses'

  task make_forums: :environment do
    Course.all.each do |cs|
      puts 'Adding forums for ' + cs.title
      cat = Forem::Category.find_by_name(cs.title)
      if !cat
        cat = Forem::Category.create(:name => cs.title)
        Forem::Forum.create(:category_id => cat.id,
                            :name => 'General Discussion',
                            :description => 'For general discussion')
        Forem::Forum.create(:category_id => cat.id,
                            :name => 'Help',
                            :description => 'Ask your questions here')
      end
    end
  end
end